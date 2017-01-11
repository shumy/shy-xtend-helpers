package shy.xhelper.data

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import shy.xhelper.data.gen.AccessorsProcessor
import shy.xhelper.data.gen.BuilderProcessor
import shy.xhelper.data.gen.GenAccessors
import shy.xhelper.data.gen.GenBuilder
import shy.xhelper.ebean.json.gen.GenJson
import shy.xhelper.ebean.json.gen.JsonProcessor

@Target(TYPE)
@Active(XDataProcessor)
annotation XData {}

class XDataProcessor extends AbstractClassProcessor {
	val genAccessors = new AccessorsProcessor
	val genBuilder = new BuilderProcessor
	val genJson = new JsonProcessor
	
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext ctx) {
		genBuilder.doRegisterGlobals(clazz, ctx)
	}
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		clazz.addAnnotation(GenJson.newAnnotationReference)
		clazz.addAnnotation(GenBuilder.newAnnotationReference)
		clazz.addAnnotation(GenAccessors.newAnnotationReference[
			setBooleanValue('onlyGetters', true)
		])
		
		genAccessors.doTransform(clazz, ctx)
		genBuilder.doTransform(clazz, ctx)
		genJson.doTransform(clazz, ctx)
		
		clazz.addMethod('toString')[
			returnType = string
			body = '''return this.toJson();'''
		]
	}
	
	override doValidate(ClassDeclaration clazz, extension ValidationContext ctx) {
		genAccessors.doValidate(clazz, ctx)
	}
}