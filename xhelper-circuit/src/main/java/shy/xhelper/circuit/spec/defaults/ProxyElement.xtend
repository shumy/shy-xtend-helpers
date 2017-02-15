package shy.xhelper.circuit.spec.defaults

import java.util.LinkedHashSet
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.XCircuit
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.IElement
import shy.xhelper.circuit.spec.IPublisher
import shy.xhelper.circuit.spec.ThreadContext

class ProxyElement<T> implements IPublisher<T>, IConnector<T> {
	@Accessors val String name
	
	public boolean active = true
	
	var boolean connected = false
	var IPublisher<T> thisPublisher = null
	var (T)=>void thisOnThen = null
	var (CircuitError)=>void thisOnError = null
	
	var boolean pipeline = false
	var IPublisher<T> tailPublisher = null
	var (T)=>void tailOnThen = null
	var ProxyElement<T> endConnector = null
	
	var XCircuit circuit = null
	val connections = new LinkedHashSet<IElement>
	
	new(String name, IElement elem) {
		circuit = ThreadContext.get(XCircuit)
		this.name = if (circuit !== null) name else '''«name»(«UUID.randomUUID.toString»)'''
		
		if (circuit !== null) {
			val elemRef = if (elem === null) this else elem
			circuit.addElement(name, elemRef)
		}
	}
	
	override getConnections() { connections }
	
	override publish(T data) {
		if (pipeline && active) {
			tailOnThen?.apply(data)
			tailPublisher?.publish(data)
		} else {
			thisOnThen?.apply(data)
			thisPublisher?.publish(data)
		}
		
		return this
	}
	
	override connect(IPublisher<T> publisher) {
		val proxy = ThreadContext.get(ProxyElement)
		if (proxy === null) {
			hardConnect(publisher)
		} else if (proxy === this) {
			//in a plugin insertion context
			if (!pipeline) {
				tailPublisher = publisher
				publisher.error[ stackError ]
			} else {
				endConnector.disconnect
				endConnector.hardConnect(publisher)
			}
		}
		
		return this
	}
	
	override then((T)=>void onThen) {
		val proxy = ThreadContext.get(ProxyElement)
		if (proxy === null) {
			hardThen(onThen)
		} else if (proxy === this) {
			//in a plugin insertion context
			if (!pipeline) {
				tailOnThen = onThen
			} else {
				endConnector.disconnect
				endConnector.hardThen(onThen)
			}
		}
		
		return this
	}
	
	override error((CircuitError)=>void onError) {
		if (thisOnError !== null)
			throw new RuntimeException("Can't reconnect error function. It was already set!")
		
		thisOnError = onError
		return this
	}
	
	def void stackError(CircuitError error) {
		error.stack.add(name)
		if (thisOnError !== null)
			thisOnError.apply(error)
		else
			throw new RuntimeException('No error interceptor on element: ' + name)
	}
	
	
	def void addConnection(IElement elem) {
		if (!ThreadContext.contains(ProxyElement))
			connections.add(elem)
	}
	
	def void removeConnection(IElement elem) {
		connections.remove(elem)
	}
	
	def void disconnect() {
		connected = false
		thisPublisher = null
		thisOnThen = null
	}
	
	def void hardConnect(IPublisher<T> publisher) {
		if (connected)
			throw new RuntimeException("Can't reconnect to publisher. It was already set!")
		connected = true
		
		connections.add(publisher)
		thisPublisher = publisher
		publisher.error[ stackError ]
	}
	
	def void hardThen((T)=>void onThen) {
		if (connected)
			throw new RuntimeException("Can't reconnect to publisher. It was already set!")
		connected = true
		
		thisOnThen = onThen
	}
	
	def void complete(ProxyElement<T> pEnd) {
		pipeline = true
		
		endConnector = pEnd
		endConnector.then[ data |
			thisOnThen?.apply(data)
			thisPublisher?.publish(data)
		]
	}
}