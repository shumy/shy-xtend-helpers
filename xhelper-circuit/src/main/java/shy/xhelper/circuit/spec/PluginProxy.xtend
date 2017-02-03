package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class PluginProxy {
	public boolean active = true
	val IElement element
	
	var boolean connected = false
	var IPublisher<Object> thisPublisher = null
	var (Object)=>void thisOnThen = null
	var (CircuitError)=>void thisOnError = null
	
	var boolean pipeline = false
	var IPublisher<Object> tailPublisher = null
	var (Object)=>void tailOnThen = null
	
	var IConnector<Object> endConnector = null
	var (Object)=>void endOnThen = null
	
	def void publish(Object data) {
		if (pipeline && active) {
			//println('''tail: «data» name:«element.name»''')
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
		val oPublisher = publisher as IPublisher<Object>
		oPublisher.error[ stackError ]
		
		val proxy = ThreadContext.get(PluginProxy)
		if (proxy === null) {
			if (connected)
				throw new RuntimeException("Can't reconnect to publisher. It was already set!")
			this.connected = true
		
			this.thisPublisher = oPublisher
		} else if (proxy === this) {
			//in a plugin insertion context
			if (!pipeline) {
				tailPublisher = oPublisher
			} else {
				endConnector.proxy.disconnect
				endConnector.connect(oPublisher)
				//TODO: complete when already exists a pipeline (insert at end)
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
			//in a plugin insertion context
			if (!pipeline) {
				tailOnThen = onThen
			} else {
				//TODO: complete when already exists a pipeline (insert at end)
			}
		}
	}
	
	def void error((CircuitError)=>void onError) {
		if (this.thisOnError !== null)
			throw new RuntimeException("Can't reconnect error function. It was already set!")
		
		this.thisOnError = onError
	}
	
	def void stackError(CircuitError error) {
		error.stack.add(element.name)
		if (thisOnError !== null)
			thisOnError.apply(error)
		else
			throw new RuntimeException('No error interceptor on element: ' + element.name)
	}
	
	def void complete(IConnector<?> pEnd) {
		pipeline = true
		
		this.endConnector = pEnd as IConnector<Object>
		this.endConnector.then[ data |
			thisOnThen?.apply(data)
			thisPublisher?.publish(data)
		]
	}
}