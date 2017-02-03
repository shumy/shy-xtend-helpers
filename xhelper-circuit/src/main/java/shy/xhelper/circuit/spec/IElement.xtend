package shy.xhelper.circuit.spec

interface IElement {
	def String getName()
	def PluginProxy getProxy()
	
	def Iterable<IElement> getConnections()
	def void stackError(CircuitError error)
}