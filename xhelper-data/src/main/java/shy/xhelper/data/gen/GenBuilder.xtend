package shy.xhelper.data.gen

import java.lang.annotation.Target
import java.util.ArrayList
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import shy.xhelper.data.Val

@Target(TYPE)
@Active(BuilderProcessor)
annotation GenBuilder {}

class BuilderProcessor extends AbstractClassProcessor {
	val genAccessors = new AccessorsProcessor
	
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext ctx) {
		registerClass(clazz.qualifiedName + 'Builder')
	}
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val allFields = clazz.declaredFields.filter[ !(transient || static) ]
		val notInitializedFields = allFields.filter[ initializer === null ].toList
		
		// not initialized fields are always not final (avoid "not assigned" incorrect errors)
		// immutability is guaranteed by setters and getters
		val finalFields = allFields.filter[ final && initializer === null ]
		finalFields.forEach[
			final = false
			addAnnotation(Val.newAnnotationReference)
		]
		
		//validate un-assigned (non optional) fields 
		val toNullValidate = new ArrayList<MutableFieldDeclaration>
		notInitializedFields.forEach[
			if (findAnnotation(Val.findTypeGlobally) !== null)
				toNullValidate.add(it)
		]
		
		
		val builderClassName = clazz.qualifiedName + 'Builder'
		val builderClazz = findClass(builderClassName)
		
		//add important fields and setters...
		notInitializedFields.forEach[ field |
			val fTypeRef = field.type.wrapperIfPrimitive
			builderClazz.addField(field.simpleName)[
				type = fTypeRef
				visibility = Visibility.DEFAULT
			]
			
			val assignedFieldName = field.simpleName + "Assigned"
			builderClazz.addField(assignedFieldName)[
				type = boolean.newTypeReference
				visibility = Visibility.DEFAULT
				initializer = '''true'''
			]
			
			builderClazz.addMethod('set' + field.simpleName.toFirstUpper)[
				addParameter(field.simpleName, field.type)
				returnType = builderClazz.newTypeReference
				body = '''
					this.«field.simpleName» = «field.simpleName»;
					this.«assignedFieldName» = true;
					return this;
				'''
			]
		]
		
		//generate getters...
		builderClazz.addAnnotation(GenAccessors.newAnnotationReference[
			setBooleanValue('onlyGetters', true)
		])
		genAccessors.doTransform(builderClazz, ctx)
		
		
		builderClazz.addMethod('operator_doubleArrow')[
			returnType = clazz.newTypeReference
			addParameter('block', Procedure1.newTypeReference(builderClazz.newTypeReference))
			body = '''
				block.apply(this);
				final «clazz.simpleName» data = new «clazz.simpleName»(this);
				return data;
			'''
		]
		
		clazz.addConstructor[
			visibility = Visibility.DEFAULT
			val builderTypeRef = newTypeReference(builderClassName)
			addParameter('builder', builderTypeRef)
			body = '''
				«FOR field: notInitializedFields»
					if (builder.«field.simpleName»Assigned) this.«field.simpleName» = builder.«field.simpleName»;
				«ENDFOR»
				
				«IF clazz.declaredMethods.exists[ simpleName == 'init' && parameters.length === 0 ]»this.init();«ENDIF»
				
				«FOR field: toNullValidate»
					if («field.simpleName» == null) throw new «RuntimeException»("Field must be initialized: «field.simpleName»");
				«ENDFOR»
			'''
		]
		
		// default constructor if not exist
		if (!clazz.declaredConstructors.exists[ simpleName == clazz.simpleName && parameters.length === 0])
			clazz.addConstructor[
				visibility = Visibility.DEFAULT
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
	
	override doValidate(ClassDeclaration clazz, extension ValidationContext ctx) {
		genAccessors.doValidate(clazz, ctx)
	}
}