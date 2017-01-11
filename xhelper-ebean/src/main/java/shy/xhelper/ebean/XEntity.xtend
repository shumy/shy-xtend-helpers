package shy.xhelper.ebean

import com.avaje.ebean.Finder
import com.avaje.ebean.Model
import java.lang.annotation.Target
import javax.persistence.Entity
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import shy.xhelper.data.gen.AccessorsProcessor
import shy.xhelper.data.gen.GenAccessors
import shy.xhelper.ebean.json.gen.GenJson
import shy.xhelper.ebean.json.gen.JsonProcessor
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.ValidationContext

@Target(TYPE)
@Active(XEntityProcessor)
annotation XEntity {
	Class<? extends Model> value = BaseModel
}

class XEntityProcessor extends AbstractClassProcessor {
	val genAccessors = new AccessorsProcessor
	val genJson = new JsonProcessor
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val ano = clazz.findAnnotation(XEntity.findTypeGlobally)
		clazz.extendedClass = ano.getClassValue('value')
		
		clazz.addAnnotation(Entity.newAnnotationReference)
		clazz.addAnnotation(GenAccessors.newAnnotationReference)
		clazz.addAnnotation(GenJson.newAnnotationReference)
			
		genAccessors.doTransform(clazz, ctx)
		genJson.doTransform(clazz, ctx)
		
		clazz.addField('find')[
			visibility = Visibility.PUBLIC
			static = true
			final = true
			type = Finder.newTypeReference(Long.newTypeReference, clazz.newTypeReference)
			initializer = '''new Finder<>(«clazz.simpleName».class)'''
		]
	}
	
	override doValidate(ClassDeclaration clazz, extension ValidationContext ctx) {
		genAccessors.doValidate(clazz, ctx)
	}
	
}