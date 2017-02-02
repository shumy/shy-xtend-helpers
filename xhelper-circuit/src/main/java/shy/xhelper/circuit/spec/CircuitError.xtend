package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Stack

@Accessors
class CircuitError {
	val String msg
	val Throwable ex
	val stack = new Stack<String>
	
	new(String msg) {
		this.msg = msg
		this.ex = null
	}
	
	new(Throwable ex) {
		this.msg = ex.message
		this.ex = ex
	}
	
	override toString() '''{ "msg":"«msg»", "stack":"«stack»", "type":"«ex?.class.simpleName»" }'''
}