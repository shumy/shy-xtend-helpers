package shy.xhelper.circuit.spec

import java.util.LinkedHashSet
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.CircuitRegistry
import shy.xhelper.circuit.XCircuit

class DefaultElement implements IElement {
	@Accessors val String name
	protected val connections = new LinkedHashSet<IElement>
	
	protected var (CircuitError)=>void onError = null
	protected var XCircuit circuit = null
	
	override getConnections() { connections }
	
	new(String name) {
		circuit = CircuitRegistry.ctx
		this.name = if (circuit !== null) name + circuit.elementPostfix else name
		
		if (circuit !== null)
			circuit.addElement(this)
	}
	
	override stackError(CircuitError error) {
		error.stack.add(name)
		if (onError !== null)
			onError.apply(error)
		else
			throw new RuntimeException('No error interceptor on element: ' + name)
	}
}