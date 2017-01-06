package shy.xtesting.descriptor

import shy.xhelper.descriptor.an.GenSchema
import shy.xhelper.descriptor.an.Optional
import shy.xhelper.descriptor.an.Public
import shy.xhelper.data.XData

@XData
@GenSchema
class GenSchemaTest {
	val static staticVar = "Not in schema"
	
	val transient transientVar = "Not in schema"
	
	val String name = "Micael"
	val String notAssigned
	
	var Integer age
	var Boolean correct
	
	@Optional float other
	
	@Public
	def changeAge(int cAge) {
		this.age = cAge
	}
	
	def notPublicMethod() {
		println(staticVar)
	}
}