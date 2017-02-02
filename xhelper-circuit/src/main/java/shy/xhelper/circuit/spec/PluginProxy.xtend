package shy.xhelper.circuit.spec

class PluginProxy<D> {
	public boolean active = true
	
	var IPublisher<D> tail = null
	var IConnector<D> end = null
	
	def void traversePublish(D data, (D)=>void onData) {
		if (tail === null) {
			onData.apply(data)
			return
		}
		
		println('''data: «data» tail:«tail.name»''')
		//end.then(onData) //TODO: can't change this
		tail.publish(data)
	}
	
	def void traverseError(CircuitError error, (CircuitError)=>void onError) {
		if (tail === null) {
			onError.apply(error)
			return
		}
		
		//tail.error(onError) //TODO: can't change this
		end.stackError(error)
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