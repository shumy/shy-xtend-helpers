package shy.xhelper.circuit.spec.defaults

import shy.xhelper.circuit.spec.IElement

abstract class Element<D> implements IElement {
	public val ProxyElement<D> proxy
	
	override getName() { proxy.name }
	override getConnections() { proxy.connections }
	
	new(String name) {
		proxy = new ProxyElement<D>(name, this)
	}
}