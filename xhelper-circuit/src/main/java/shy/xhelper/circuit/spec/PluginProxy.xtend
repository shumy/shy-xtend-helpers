package shy.xhelper.circuit.spec

class PluginProxy<D> {
	public boolean active = true
	
	var IPublisher<D> tail = null
	var IConnector<D> end = null
	
	def void traversePublish(D data, (D)=>void onData) {
		if (tail === null)
			onData.apply(data)
		
		tail.publish(data)
		end.then(onData)
	}
	
	def void traverseError(CircuitError error, (CircuitError)=>void onError) {
		if (tail === null)
			onError.apply(error)
		
		tail.error(onError)
		(end as DefaultElement).stackError(error)
	}
	
	def void connect(IPublisherConnector<D> plugin) {
		if (this.tail === null) {
			this.tail = plugin
		} else {
			this.end.connect(plugin)
		}
		
		this.end = plugin
	}
}