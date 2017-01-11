package shy.xhelper.data.gen

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import shy.xhelper.data.Val

@Target(TYPE)
@Active(AccessorsProcessor)
annotation GenAccessors {
	boolean onlyGetters = false
}

class AccessorsProcessor extends AbstractClassProcessor {
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val anno = clazz.findAnnotation(GenAccessors.findTypeGlobally)
		
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		val nonFinalFields = allFields.filter[ !(final || findAnnotation(Val.findTypeGlobally) !== null) ]
		
		allFields.forEach[ field |
			field.markAsRead
			
			val getType = if (field.type == boolean.newTypeReference || field.type == Boolean.newTypeReference) 'is' else 'get'
			val methName = getType + field.simpleName.toFirstUpper
			
			//don't generate if already defined by the user...
			if (!clazz.declaredMethods.exists[ simpleName == methName && parameters.length === 0])
				clazz.addMethod(methName)[
					addAnnotation(Pure.newAnnotationReference)
					returnType = field.type
					body = '''
						return this.«field.simpleName»;
					'''
				]
		]
		
		if (!anno.getBooleanValue('onlyGetters'))
			nonFinalFields.forEach[ field |
				val methName = 'set' + field.simpleName.toFirstUpper
				
				//don't generate if already defined by the user...
				if (!clazz.declaredMethods.exists[ simpleName == methName && parameters.length === 1 && parameters.get(0).type == field.type])
					clazz.addMethod(methName)[
						addParameter(field.simpleName, field.type)
						returnType = clazz.newTypeReference
						body = '''
							this.«field.simpleName» = «field.simpleName»;
							return this;
						'''
					]
			]
	}
	
	override doValidate(ClassDeclaration clazz, extension ValidationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		allFields.forEach[
			if (type.primitive)
				addError('''Primitive value: use boxed values instead.''')
		]
	}
}