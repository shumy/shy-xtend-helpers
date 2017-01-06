package shy.xhelper.data

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

@Target(TYPE)
@Active(XDataProcessor)
annotation XData {}

class XDataProcessor extends AbstractClassProcessor {
	val genBuilder = new BuilderProcessor
	val genAccessors = new AccessorsProcessor
	
	override doRegisterGlobals(ClassDeclaration clazz, extension RegisterGlobalsContext ctx) {
		genBuilder.doRegisterGlobals(clazz, ctx)
	}
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		clazz.addAnnotation(GenBuilder.newAnnotationReference)
		
		clazz.addAnnotation(GenAccessors.newAnnotationReference[
			setBooleanValue('onlyGetters', true)
		])
		
		genAccessors.doTransform(clazz, ctx)
		genBuilder.doTransform(clazz, ctx)
	}
}