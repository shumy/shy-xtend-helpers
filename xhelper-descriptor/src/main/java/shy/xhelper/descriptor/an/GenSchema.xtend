package shy.xhelper.descriptor.an

import com.google.common.collect.ImmutableList
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import shy.xhelper.descriptor.ISchema
import shy.xhelper.descriptor.SMethod
import shy.xhelper.descriptor.SProperty
import shy.xhelper.descriptor.SType

@Target(TYPE)
@Active(SchemaProcessor)
annotation GenSchema {}

class SchemaProcessor extends AbstractClassProcessor {
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		val allMethods = clazz.declaredMethods.filter[ findAnnotation(Public.findTypeGlobally) != null ]
		
		clazz.extendedClass = ISchema.newTypeReference
		
		clazz.addField('properties')[
			visibility = Visibility.PUBLIC
			transient = true
			static = true
			final = true
			type = List.newTypeReference(SProperty.newTypeReference)
			initializer = '''«ImmutableList».copyOf(new SProperty[] {
				«FOR prop: allFields SEPARATOR ','»
					«ctx.propertyInitializer(prop)»
				«ENDFOR»
			})'''
		]
		
		clazz.addField('methods')[
			visibility = Visibility.PUBLIC
			transient = true
			static = true
			final = true
			type = List.newTypeReference(SMethod.newTypeReference)
			initializer = '''«ImmutableList».copyOf(new SMethod[] {
				«FOR meth: allMethods SEPARATOR ','»
					«ctx.methodInitializer(meth)»
				«ENDFOR»
			})'''
		]
		
		clazz.addMethod('getProperties')[
			returnType = List.newTypeReference(SProperty.newTypeReference)
			body = '''
				return properties;
			'''
		]
		
		clazz.addMethod('getMethods')[
			returnType = List.newTypeReference(SMethod.newTypeReference)
			body = '''
				return methods;
			'''
		]
	}
	
	def propertyInitializer(extension TransformationContext ctx, MutableFieldDeclaration prop) {
		val isOptional = prop.findAnnotation(Optional.findTypeGlobally) != null
		
		'''
			new SProperty("«prop.simpleName»", «prop.type.typeInitializer», «isOptional»)
		'''
	}
	
	def methodInitializer(extension TransformationContext ctx, MutableMethodDeclaration meth) {
		//do not use additional context parameters
		val originalParams = meth.parameters.filter[ primarySourceElement != null ]
		
		'''
			new SMethod("«meth.simpleName»", «meth.returnType.typeInitializer», «ImmutableList.simpleName».copyOf(new «SProperty.canonicalName»[] {
				«FOR param: originalParams SEPARATOR ','»
					«ctx.parameterInitializer(param)»
				«ENDFOR»
			}))
		'''
	}
	
	def parameterInitializer(extension TransformationContext ctx, MutableParameterDeclaration param)
		'''new «SProperty.canonicalName»("«param.simpleName»", «param.type.typeInitializer»)'''
	
	def typeInitializer(TypeReference rType) {
		val type = rType.wrapperIfPrimitive.name.split('<').get(0)
		val argTypes = rType.actualTypeArguments.map[ name.split('<').get(0) ]
		
		'''«SType.canonicalName».from(«type».class«IF argTypes.length != 0», «ENDIF»«FOR arg: argTypes SEPARATOR ', '»«arg».class«ENDFOR»)'''
	}
}