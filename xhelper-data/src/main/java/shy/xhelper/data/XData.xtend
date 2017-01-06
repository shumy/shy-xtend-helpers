package shy.xhelper.data

import java.lang.annotation.Target
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Target(TYPE)
@Active(XDataProcessor)
annotation XData {}

class XDataProcessor extends AbstractClassProcessor {
	val genBuilder = new BuilderProcessor
	val genAccessors = new AccessorsProcessor
	
	val validTypes = #{
		'String', 'Boolean', 'Integer', 'Long', 'Float', 'Double',
		'LocalDate', 'LocalTime', 'LocalDateTime'
	}
	
	override doValidate(ClassDeclaration clazz, extension ValidationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		allFields.forEach[
			if (!validTypes.contains(type.simpleName))
				addError('''Only primitives «validTypes» are valid for Data structures!''')
		]
	}
	
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext ctx) {
		genBuilder.doRegisterGlobals(clazz, ctx)
	}
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		
		clazz.addAnnotation(GenBuilder.newAnnotationReference)
		clazz.addAnnotation(GenAccessors.newAnnotationReference[
			setBooleanValue('onlyGetters', true)
		])
		
		genAccessors.doTransform(clazz, ctx)
		genBuilder.doTransform(clazz, ctx)
		
		clazz.addMethod('toString')[
			returnType = string
			body = '''
				final «StringBuilder» sb = new StringBuilder("{ ");
					«FOR field: allFields SEPARATOR ' sb.append(", ");'»
						sb.append("«field.simpleName»"); sb.append(": \""); sb.append(«field.getFieldValue(ctx)»); sb.append("\"");
					«ENDFOR»
				sb.append(" }");
				return sb.toString();
			'''
		]
	}
	
	def getFieldValue(FieldDeclaration field, extension TransformationContext ctx) {
		switch field.type {
			case LocalDate.newTypeReference: '''«field.simpleName».format(«DateTimeFormatter.name».ISO_LOCAL_DATE)'''
			case LocalTime.newTypeReference: '''«field.simpleName».format(«DateTimeFormatter.name».ISO_LOCAL_TIME)'''
			case LocalDateTime.newTypeReference: '''«field.simpleName».format(«DateTimeFormatter.name».ISO_LOCAL_DATE_TIME)'''
			default: field.simpleName
		}
	}
}