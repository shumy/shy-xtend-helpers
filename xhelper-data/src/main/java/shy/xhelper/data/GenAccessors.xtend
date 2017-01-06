package shy.xhelper.data

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext

@Target(TYPE)
@Active(AccessorsProcessor)
annotation GenAccessors {
	boolean onlyGetters = false
}

class AccessorsProcessor extends AbstractClassProcessor {
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val anno = clazz.findAnnotation(GenAccessors.findTypeGlobally)
		
		val allFields = clazz.declaredFields.filter[ !static ]
		val nonFinalFields = allFields.filter[ !final ]
		
		allFields.forEach[ field |
			field.markAsRead
			
			val getType = if (field.type == boolean.newTypeReference || field.type == Boolean.newTypeReference) 'is' else 'get'
			clazz.addMethod(getType + field.simpleName.toFirstUpper)[
				returnType = field.type
				body = '''
					return this.«field.simpleName»;
				'''
			]
		]
		
		if (!anno.getBooleanValue('onlyGetters'))
			nonFinalFields.forEach[ field |
				clazz.addMethod('set' + field.simpleName.toFirstUpper)[
					addParameter(field.simpleName, field.type)
					returnType = clazz.newTypeReference
					body = '''
						this.«field.simpleName» = «field.simpleName»;
						return this;
					'''
				]
			]
	}
}