package shy.xhelper.circuit

import java.util.LinkedHashSet
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.defaults.ProxyElement
import shy.xhelper.circuit.spec.defaults.Element
import shy.xhelper.circuit.spec.IPublisher

@FinalFieldsConstructor
class XSwitcher<D> extends Element<D> implements IPublisher<D> {
	val branches = new LinkedHashSet<Branch<D>>
	
	def Iterable<Branch<D>> getBranches() { branches }
	
	def void remove(IConnector<D> branch) {
		branches.remove(branch)
		proxy.removeConnection(branch)
	}
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		for (branch: new LinkedHashSet(branches))
			branch.publish(data)
		
		return this
	}
	
	override error((CircuitError)=>void onError) {
		proxy.error(onError)
	}
	
	def when((D)=>boolean condition) {
		val branch = new Branch('''«name»-B«branches.size»''', condition)
		proxy.addConnection(branch)
		
		branch.error[ proxy.stackError(it) ]
		branches.add(branch)
		return branch
	}
}

class Branch<D> extends ProxyElement<D> {
	val (D)=>boolean condition
	
	package new(String name, (D)=>boolean condition) {
		super(name, null)
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