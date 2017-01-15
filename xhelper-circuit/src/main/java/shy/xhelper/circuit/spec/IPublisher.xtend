package shy.xhelper.circuit.spec

interface IPublisher<T> extends IName {
	def IPublisher<T> publish(T data)
	def IPublisher<T> error((Error)=>void onError)
}