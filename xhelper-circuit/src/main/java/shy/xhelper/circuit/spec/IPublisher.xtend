package shy.xhelper.circuit.spec

interface IPublisher<T> extends IElement {
	def IPublisher<T> publish(T data)
	def IPublisher<T> error((CircuitError)=>void onError)
}