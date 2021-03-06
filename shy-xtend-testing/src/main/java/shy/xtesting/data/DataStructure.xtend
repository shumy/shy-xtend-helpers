package shy.xtesting.data

import java.time.LocalDate
import java.time.Month
import shy.xhelper.data.Val
import shy.xhelper.data.XData
import shy.xhelper.descriptor.Public
import shy.xhelper.descriptor.gen.GenSchema
import shy.xhelper.ebean.json.gen.GenJson

@XData
@GenSchema
@GenJson
class DataStructure {
	// (static, transient, pre-assigned) fields are not part of the builder
	val static staticVar = "Not in schema"
	val transient transientVar = "Not in schema"
	val String name = "Micael"
	val LocalDate dt = LocalDate.of(2017, Month.JANUARY, 1)
	
	// marked as final (no setters are generated)
	// internal types are not final, and can be initialized e.g: by ORM frameworks
	// validated after init()
	val String notAssigned1
	@Val String notAssigned2
	
	// marked as optional (setters can be generated)
	Integer age
	Boolean correct
	Float other
	
	//invoked after builder construction...
	def init() {
		notAssigned2 = "n2!"
	}
	
	@Public
	def changeAge(int cAge) {
		this.age = cAge
	}
	
	def notPublicMethod() {
		println(staticVar)
	}
}