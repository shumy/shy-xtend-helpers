package shy.xhelper.circuit.spec

interface IElement {
	def String getName()
	def Iterable<IElement> getConnections()
}