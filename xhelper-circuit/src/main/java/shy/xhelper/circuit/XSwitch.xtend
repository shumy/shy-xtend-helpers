package shy.xhelper.circuit

import java.util.HashSet
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.circuit.spec.DefaultIO
import shy.xhelper.circuit.spec.DefaultPublisher
import shy.xhelper.circuit.spec.Error

@Accessors
class XSwitch<D> extends DefaultPublisher<D> {
	val Set<Branch<D>> branches = new HashSet<Branch<D>>
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		for (b: new HashSet(branches))
			Async.run([ b.condition.apply(data) ], [ if(it) b.publish(data) ], [
				b.stackError(new Error(message, it))
			])
		
		return this
	}
	
	@XAsynchronous
	def when((D)=>boolean condition) {
		val branch = new Branch('''«name»-B«branches.size»''', condition)
		branch.error[ stackError ]
		
		branches.add(branch)
		return branch
	}
}

@Accessors
class Branch<D> extends DefaultIO<D> {
	val (D)=>boolean condition
}