package shy.xhelper.circuit.spec

interface IConnector<T> extends IElement {
	def IConnector<T> connect(IPublisher<T> publisher)
	def IConnector<T> then((T)=>void onThen)
}