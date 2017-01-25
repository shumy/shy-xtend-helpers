package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors(NONE)
class DefaultPublisher<D> extends DefaultElement implements IPublisher<D> {
	protected var IPublisher<D> publisher = null
	protected var (D)=>void onThen = null
	
	override publish(D data) {
		publisher?.publish(data)
		onThen?.apply(data)
		return this
	}
	
	override error((CircuitError)=>void onError) {
		if (this.onError !== null)
			throw new RuntimeException("Can't override Pipeline error. It was already set!")
			
		this.onError = onError
		return this
	}
}