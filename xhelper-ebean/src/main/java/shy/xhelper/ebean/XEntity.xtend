package shy.xhelper.ebean

import com.avaje.ebean.Finder
import com.avaje.ebean.Model
import com.fasterxml.jackson.databind.annotation.JsonDeserialize
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import java.lang.annotation.Target
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import javax.persistence.Entity
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import shy.xhelper.data.gen.AccessorsProcessor
import shy.xhelper.data.gen.GenAccessors
import shy.xhelper.ebean.json.EntityRefSerializer
import shy.xhelper.ebean.json.LocalDateDeserializer
import shy.xhelper.ebean.json.LocalDateSerializer
import shy.xhelper.ebean.json.LocalDateTimeDeserializer
import shy.xhelper.ebean.json.LocalDateTimeSerializer
import shy.xhelper.ebean.json.LocalTimeDeserializer
import shy.xhelper.ebean.json.LocalTimeSerializer

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
			//Date default converters...
			if (type == LocalDate.newTypeReference) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', LocalDateSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', LocalDateDeserializer.newTypeReference) ])
			}
			
			//Time default converters...
			if (type == LocalTime.newTypeReference) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', LocalTimeSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', LocalTimeDeserializer.newTypeReference) ])
			}
			
			//DateTime default converters...
			if (type == LocalDateTime.newTypeReference) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', LocalDateTimeSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', LocalDateTimeDeserializer.newTypeReference) ])
			}
			
			//if the field is an Entity ref -> add RefConverters
			if (BaseModel.newTypeReference.isAssignableFrom(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', EntityRefSerializer.newTypeReference) ])
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
					return jMapper.readValue(jsonString, «clazz.simpleName».class);
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
					return jMapper.writeValueAsString(this);
				} catch(«Throwable» ex) {
					throw new «RuntimeException»(ex);
				}
			'''
		]
	}
}