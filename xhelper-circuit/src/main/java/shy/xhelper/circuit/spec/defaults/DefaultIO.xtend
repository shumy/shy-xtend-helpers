package shy.xhelper.circuit.spec.defaults

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.circuit.spec.IPublisher
import shy.xhelper.circuit.spec.IPublisherConnector

@FinalFieldsConstructor
class DefaultIO<D> extends DefaultPublisher<D> implements IPublisherConnector<D> {
	override connect(IPublisher<D> publisher) {
		addConnection(publisher)
		proxy.connect(publisher)
		return this
	}
	
	override then((D)=>void onThen) {
		proxy.then(onThen as (Object)=>void)
		return this
	}
}