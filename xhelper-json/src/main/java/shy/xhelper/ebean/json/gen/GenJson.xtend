package shy.xhelper.ebean.json.gen

import com.fasterxml.jackson.databind.annotation.JsonDeserialize
import com.fasterxml.jackson.databind.annotation.JsonSerialize
import java.lang.annotation.Target
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import shy.xhelper.ebean.json.JsonDynamicProfile
import shy.xhelper.ebean.json.converter.CollectionDeserializer
import shy.xhelper.ebean.json.converter.CollectionSerializer
import shy.xhelper.ebean.json.converter.LocalDateTimeDeserializer
import shy.xhelper.ebean.json.converter.LocalDateTimeSerializer
import shy.xhelper.ebean.json.converter.RefDeserializer
import shy.xhelper.ebean.json.converter.RefSerializer

@Target(TYPE)
@Active(JsonProcessor)
annotation GenJson {}

class JsonProcessor extends AbstractClassProcessor {
	val primitiveTypes = #{ 'String', 'Boolean', 'Integer', 'Long', 'Float', 'Double' }
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		
		allFields.forEach[
			if (type.inferred) {
				addError('GenJson can\'t use inferred types.')
				return
			}
			
			if (#{LocalDate.newTypeReference, LocalTime.newTypeReference, LocalDateTime.newTypeReference}.contains(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', LocalDateTimeSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', LocalDateTimeDeserializer.newTypeReference) ])
			} else if (Iterable.newTypeReference.isAssignableFrom(type)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', CollectionSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', CollectionDeserializer.newTypeReference) ])
			} else if (!primitiveTypes.contains(type.simpleName)) {
				addAnnotation(JsonSerialize.newAnnotationReference[ setClassValue('using', RefSerializer.newTypeReference) ])
				addAnnotation(JsonDeserialize.newAnnotationReference[ setClassValue('using', RefDeserializer.newTypeReference) ])
			}
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