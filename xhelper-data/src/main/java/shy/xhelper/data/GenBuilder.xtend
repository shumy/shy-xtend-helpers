package shy.xhelper.data

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

@Target(TYPE)
@Active(BuilderProcessor)
annotation GenBuilder {}

class BuilderProcessor extends AbstractClassProcessor {
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext ctx) {
		registerClass(clazz.qualifiedName + 'Builder')
	}
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		val assignableFields = allFields.filter[ !final && initializer === null ]
		val finalFields = allFields.filter[ final && initializer === null ]
		
		
		val builderClassName = clazz.qualifiedName + 'Builder'
		val builderClazz = findClass(builderClassName)
		
		allFields.forEach[ field |
			val fTypeRef = field.type.wrapperIfPrimitive
			
			builderClazz.addField(field.simpleName)[
				type = fTypeRef
				visibility = Visibility.PUBLIC
			]
		]
		
		
		builderClazz.addConstructor[
			visibility = Visibility.DEFAULT
			body = '''//default empty constructor'''
		]
		
		builderClazz.addMethod('operator_doubleArrow')[
			returnType = clazz.newTypeReference
			addParameter('block', Procedure1.newTypeReference(builderClazz.newTypeReference))
			body = '''
				block.apply(this);
				final «clazz.simpleName» data = new «clazz.simpleName»(this);
				return data;
			'''
		]
		
		if (!finalFields.empty)
			clazz.addConstructor[
				visibility = Visibility.PUBLIC
				for (field: finalFields)
					addParameter(field.simpleName, field.type)
				
				body = '''
					«FOR field: finalFields»
						this.«field.simpleName» = «field.simpleName»;
					«ENDFOR»
				'''
			]
		
		clazz.addConstructor[
			visibility = Visibility.DEFAULT
			val builderTypeRef = newTypeReference(builderClassName)
			addParameter('builder', builderTypeRef)
			body = '''
				this(«FOR field: finalFields SEPARATOR ','»builder.«field.simpleName»«ENDFOR»);
				«FOR field: assignableFields»
					this.«field.simpleName» = builder.«field.simpleName»;
				«ENDFOR»
			'''
		]
		
		//add default constructor if not exist
		if (finalFields.empty && !clazz.declaredConstructors.exists[ simpleName == clazz.simpleName && parameters.length === 0])
			clazz.addConstructor[
				visibility = Visibility.PUBLIC
				body = '''//default empty constructor'''
			]
		
		clazz.addMethod('B')[
			static = true
			returnType = builderClazz.newTypeReference
			body = '''
				return new «builderClassName»();
			'''
		]
		
		//this one only works when using static extension imports!
		clazz.addMethod('operator_doubleArrow') [
			static = true
			returnType = clazz.newTypeReference
			addParameter('left', Class.newTypeReference(clazz.newTypeReference))
			addParameter('block', Procedure1.newTypeReference(builderClazz.newTypeReference))
			body = '''
				final «builderClazz.simpleName» builder = new «builderClazz.simpleName»(); 
				block.apply(builder);
				final «clazz.simpleName» data = new «clazz.simpleName»(builder);
				return data;
			'''
		]
	}
}