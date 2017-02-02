package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@FinalFieldsConstructor
class DefaultIO<D> extends DefaultPublisher<D> implements IPublisherConnector<D> {
	var connected = false
	
	override connect(IPublisher<D> publisher) {
		if (connected)
			throw new RuntimeException("Can't reconnect to publisher. It was already set!")
		
		publisher.error[ stackError ]
		connections.add(publisher)
		
		this.connected = true
		this.publisher = publisher
		return this
	}
	
	override then((D)=>void onThen) {
		if (connected)
			throw new RuntimeException("Can't reconnect to publisher. It was already set!")
		
		this.connected = true
		this.onThen = onThen
		return this
	}
}