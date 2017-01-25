package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(NONE)
class DefaultIO<D> extends DefaultPublisher<D> implements IConnector<D> {
	
	override connect(IPublisher<D> publisher) {
		if (this.publisher !== null)
			throw new RuntimeException("Can't override Pipeline connect. It was already set!")
		
		publisher.error[ stackError ]
		this.publisher = publisher
		return this
	}
	
	override then((D)=>void onThen) {
		if (this.onThen !== null)
			throw new RuntimeException("Can't override Pipeline then. It was already set!")
		
		this.onThen = onThen
		return this
	}
}