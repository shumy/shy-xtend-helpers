package shy.xhelper.circuit

import shy.xhelper.circuit.spec.IConnector

class CircuitExtensions {
	static def <D> pipeline(IConnector<D> con, String name) {
		val next = new XPipeline<D>(name)
		con.connect(next)
		return next
	}
	
	static def <D> switcher(IConnector<D> con, String name) {
		val next = new XSwitcher<D>(name)
		con.connect(next)
		return next
	}
}