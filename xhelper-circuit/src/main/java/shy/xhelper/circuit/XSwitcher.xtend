package shy.xhelper.circuit

import java.util.LinkedHashSet
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.defaults.ProxyElement

@FinalFieldsConstructor
class XSwitcher<D> extends ProxyElement<D> {
	val branches = new LinkedHashSet<Branch<D>>
	
	def Iterable<Branch<D>> getBranches() { branches }
	
	def void remove(IConnector<D> branch) {
		branches.remove(branch)
		connections.remove(branch)
	}
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		for (branch: new LinkedHashSet(branches))
			branch.publish(data)
		
		return this
	}
	
	def when((D)=>boolean condition) {
		val branch = new Branch('''«name»-B«branches.size»''', condition)
		addConnection(branch)
		
		branch.error[ stackError ]
		branches.add(branch)
		return branch
	}
}

class Branch<D> extends ProxyElement<D> {
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
			stackError(new CircuitError(ex))
			return null
		}
	}
}