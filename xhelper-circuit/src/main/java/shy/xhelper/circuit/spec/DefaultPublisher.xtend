package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.annotations.Accessors

@FinalFieldsConstructor
class DefaultPublisher<D> extends DefaultElement implements IPublisher<D> {
	@Accessors val proxy = new PluginProxy<D>
	
	protected var IPublisher<D> publisher = null
	protected var (D)=>void onThen = null
	
	override publish(D data) {
		proxy.traversePublish(data)[
			publisher?.publish(it)
			onThen?.apply(it)
		]
		
		return this
	}
	
	override error((CircuitError)=>void onError) {
		if (this.onError !== null)
			throw new RuntimeException("Can't override Pipeline error. It was already set!")
		
		this.onError = [
			proxy.traverseError(it, onError)
		]
		
		return this
	}
}