package shy.xhelper.circuit.spec.defaults

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IPublisher

@FinalFieldsConstructor
class DefaultPublisher<D> extends DefaultElement implements IPublisher<D> {
	override publish(D data) {
		proxy.publish(data)
		return this
	}
	
	override error((CircuitError)=>void onError) {
		proxy.error(onError)
		return this
	}
}