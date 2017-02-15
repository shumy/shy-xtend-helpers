package shy.xhelper.circuit

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.defaults.Element
import shy.xhelper.circuit.spec.IPublisher
import shy.xhelper.circuit.spec.IConnector

@FinalFieldsConstructor
class XPipeline<D> extends Element<D> implements IPublisher<D>, IConnector<D> {
	
	override error((CircuitError)=>void onError) {
		proxy.error(onError)
	}
	
	override publish(D data) {
		proxy.publish(data)
	}
	
	override connect(IPublisher<D> publisher) {
		proxy.connect(publisher)
	}
	
	override then((D)=>void onThen) {
		proxy.then(onThen)
	}
	
	@XAsynchronous
	def <T> map((D)=>T transform) {
		val newPipe = new XPipeline<T>(name + '-M')
		proxy.addConnection(newPipe)
		
		newPipe.error[ proxy.stackError(it) ]
		then[ data |
			Async.run([ transform.apply(data) ], [ newPipe.publish(it) ], [
				newPipe.proxy.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def filter((D)=>boolean filter) {
		val newPipe = new XPipeline<D>(name + '-F')
		proxy.addConnection(newPipe)
		
		newPipe.error[ proxy.stackError(it) ]
		then[ data |
			Async.run([ filter.apply(data) ], [ if(it !== null && it) newPipe.publish(data) ], [
				newPipe.proxy.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def forEach((D)=>Void process) {
		val newPipe = new XPipeline<D>(name + '-E')
		proxy.addConnection(newPipe)
		
		newPipe.error[ proxy.stackError(it) ]
		then[ data |
			Async.run([ process.apply(data) ], [ newPipe.publish(data) ], [
				newPipe.proxy.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
}