package shy.xhelper.circuit

import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.defaults.DefaultIO

@FinalFieldsConstructor
class XPipeline<D> extends DefaultIO<D> {
	
	@XAsynchronous
	def <T> map((D)=>T transform) {
		val newPipe = new XPipeline<T>(name + '-M')
		addConnection(newPipe)
		
		newPipe.error[ stackError ]
		then[ data |
			Async.run([ transform.apply(data) ], [ newPipe.publish(it) ], [
				newPipe.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def filter((D)=>boolean filter) {
		val newPipe = new XPipeline<D>(name + '-F')
		addConnection(newPipe)
		
		newPipe.error[ stackError ]
		then[ data |
			Async.run([ filter.apply(data) ], [ if(it !== null && it) newPipe.publish(data) ], [
				newPipe.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def forEach((D)=>Void process) {
		val newPipe = new XPipeline<D>(name + '-E')
		addConnection(newPipe)
		
		newPipe.error[ stackError ]
		then[ data |
			Async.run([ process.apply(data) ], [ newPipe.publish(data) ], [
				newPipe.stackError(new CircuitError(it))
			])
		]
		
		return newPipe
	}
}