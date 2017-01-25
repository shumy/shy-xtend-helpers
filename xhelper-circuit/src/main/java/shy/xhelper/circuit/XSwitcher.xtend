package shy.xhelper.circuit

import java.util.HashSet
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.spec.DefaultIO
import shy.xhelper.circuit.spec.DefaultPublisher
import shy.xhelper.circuit.spec.CircuitError

@Accessors
class XSwitcher<D> extends DefaultPublisher<D> {
	val Set<Branch<D>> branches = new HashSet<Branch<D>>
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		for (branch: new HashSet(branches))
			branch.publish(data)
		
		return this
	}
	
	def when((D)=>boolean condition) {
		val branch = new Branch('''«name»-B«branches.size»''', condition)
		branch.error[ stackError ]
		
		branches.add(branch)
		return branch
	}
}

class Branch<D> extends DefaultIO<D> {
	val (D)=>boolean condition
	
	package new(String name, (D)=>boolean condition) {
		super(name)
		this.condition = condition
	}
	
	override publish(D data) {
		try {
			if (condition.apply(data))
				return super.publish(data)
		} catch(Throwable ex) {
			stackError(new CircuitError(ex.message, ex))
			return null
		}
	}
}