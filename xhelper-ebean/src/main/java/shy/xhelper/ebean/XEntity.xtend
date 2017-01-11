package shy.xhelper.ebean

import com.avaje.ebean.Finder
import com.avaje.ebean.Model
import com.fasterxml.jackson.databind.annotation.JsonDeserialize
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import java.lang.annotation.Target
import java.time.LocalDateTime
import javax.persistence.Entity
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import shy.xhelper.data.gen.AccessorsProcessor
import shy.xhelper.data.gen.GenAccessors
import shy.xhelper.ebean.json.JsonDynamicProfile
import shy.xhelper.ebean.json.converter.LocalDateTimeDeserializer
import shy.xhelper.ebean.json.converter.LocalDateTimeSerializer
import shy.xhelper.ebean.json.converter.RefSerializer
import java.time.LocalTime
import java.time.LocalDate
import shy.xhelper.ebean.json.converter.CollectionSerializer
import shy.xhelper.ebean.json.converter.RefDeserializer
import shy.xhelper.ebean.json.converter.CollectionDeserializer

@Target(TYPE)
@Active(XEntityProcessor)
annotation XEntity {
	Class<? extends Model> value = BaseModel
}

class XEntityProcessor extends AbstractClassProcessor {
	val genAccessors = new AccessorsProcessor
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		
		val ano = clazz.findAnnotation(XEntity.findTypeGlobally)
		clazz.extendedClass = ano.getClassValue('value')
		
		clazz.addAnnotation(Entity.newAnnotationReference)
		clazz.addAnnotation(GenAccessors.newAnnotationReference)
			
		genAccessors.doTransform(clazz, ctx)
		
		allFields.forEach[
			if (#{LocalDate.newTypeReference, LocalTime.newTypeReference, LocalDateTime.newTypeReference}.contains(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', LocalDateTimeSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', LocalDateTimeDeserializer.newTypeReference) ])
			}
			
			if (BaseModel.newTypeReference.isAssignableFrom(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', RefSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', RefDeserializer.newTypeReference) ])
			}
			
			if (Iterable.newTypeReference.isAssignableFrom(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', CollectionSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', CollectionDeserializer.newTypeReference) ])
			}
		]
		
		clazz.addField('find')[
			visibility = Visibility.PUBLIC
			static = true
			final = true
			type = Finder.newTypeReference(Long.newTypeReference, clazz.newTypeReference)
			initializer = '''new Finder<>(«clazz.simpleName».class)'''
		]
		
		clazz.addMethod('fromJson')[
			visibility = Visibility.PUBLIC
			static = true
			returnType = clazz.newTypeReference
			addParameter('jsonString', string)
			body = '''
				try {
					return «JsonDynamicProfile».deserialize(«clazz.simpleName».class, jsonString);
				} catch(«Throwable» ex) {
					throw new «RuntimeException»(ex);
				}
			'''
		]
		
		clazz.addMethod('toJson')[
			visibility = Visibility.PUBLIC
			returnType = string
			body = '''
				try {
					return «JsonDynamicProfile».serialize(this);
				} catch(«Throwable» ex) {
					throw new «RuntimeException»(ex);
				}
			'''
		]
	}
}