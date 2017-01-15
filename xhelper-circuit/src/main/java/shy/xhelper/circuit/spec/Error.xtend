package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Stack

@Accessors
class Error {
	val String msg
	val Throwable ex
	val stack = new Stack<String>
	
	new(String msg) { this(msg, null) }
	new(String msg, Throwable ex) {
		this.msg = msg
		this.ex = ex
	}
	
	override toString() '''{ "msg":"«msg»", "stack":"«stack»", "type":"«ex?.class.simpleName»" }'''
}