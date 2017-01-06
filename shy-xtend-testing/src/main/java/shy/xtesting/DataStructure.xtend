package shy.xtesting

import java.time.LocalDate
import java.time.Month
import shy.xhelper.data.XData
import shy.xhelper.descriptor.an.GenSchema
import shy.xhelper.descriptor.an.Public
import shy.xhelper.data.Val

@XData
@GenSchema
class DataStructure {
	// (static, transient, pre-assigned) fields are not part of the builder
	val static staticVar = "Not in schema"
	val transient transientVar = "Not in schema"
	val name = "Micael"
	val dt = LocalDate.of(2017, Month.JANUARY, 1)
	
	// marked as final (no setters are generated)
	// internal types are not final, and can be initialized e.g: by ORM frameworks
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