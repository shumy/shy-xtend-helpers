package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class PluginProxy {
	public boolean active = true
	val IElement element
	
	var boolean connected = false
	var IPublisher thisPublisher = null
	var (Object)=>void thisOnThen = null
	var (CircuitError)=>void thisOnError = null
	
	var boolean pipeline = false
	var IPublisher tailPublisher = null
	var (Object)=>void tailOnThen = null
	var (CircuitError)=>void tailOnError = null
	
	var IConnector endConnector = null
	var (Object)=>void endOnThen = null
	var (CircuitError)=>void endOnError = null
	
	def void publish(Object data) {
		if (pipeline && active) {
			println('''tail: «data» name:«element.name»''')
			tailOnThen?.apply(data)
			tailPublisher?.publish(data)
		} else {
			//println('''this: «data» name:«element.name»''')
			thisOnThen?.apply(data)
			thisPublisher?.publish(data)
		}
	}
	
	def void disconnect() {
		connected = false
		this.thisPublisher = null
		this.thisOnThen = null
		this.thisOnError = null
	}
	
	def void connect(IPublisher<?> publisher) {
		publisher.error[ stackError ]
		
		val proxy = ThreadContext.get(PluginProxy)
		if (proxy === null) {
			if (connected)
				throw new RuntimeException("Can't reconnect to publisher. It was already set!")
			this.connected = true
		
			this.thisPublisher = publisher
		} else if (proxy === this) {
			//in a plugin insertion context
			if (!pipeline) {
				tailPublisher = publisher
			}
		}
	}
	
	def void then((Object)=>void onThen) {
		val proxy = ThreadContext.get(PluginProxy)
		if (proxy === null) {
			if (connected)
				throw new RuntimeException("Can't reconnect to publisher. It was already set!")
			this.connected = true
		
			this.thisOnThen = onThen
		} else if (proxy === this) {
			//in a plugin insertion context (if this is the proxy -> insert at end)
			if (!pipeline) {
				tailOnThen = onThen
			}
		}
	}
	
	def void error((CircuitError)=>void onError) {
		val proxy = ThreadContext.get(PluginProxy)
		if (proxy === null) {
			if (this.thisOnError !== null)
				throw new RuntimeException("Can't reconnect error function. It was already set!")
		
			this.thisOnError = onError
		} else if (proxy === this) {
			//in a plugin insertion context (if this is the proxy -> insert at end)
			
		}
	}
	
	def void stackError(CircuitError error) {
		error.stack.add(element.name)
		
		/*if (pipeline && active)
			endPublisher.stackError(error)
		else {*/
			if (thisOnError !== null)
				thisOnError.apply(error)
			else
				throw new RuntimeException('No error interceptor on element: ' + element.name)	
		//}
	}
	
	def void complete(IPublisherConnector<?> pEnd) {
		//TODO: complete context initiated by XCircuit.plugin
		
		pipeline = true
		
		this.endConnector = pEnd
		this.endConnector.then[ data |
			thisOnThen?.apply(data)
			thisPublisher?.publish(data)
		]
	}
}