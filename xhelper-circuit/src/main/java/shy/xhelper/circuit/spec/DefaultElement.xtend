package shy.xhelper.circuit.spec

import java.util.LinkedHashSet
import org.eclipse.xtend.lib.annotations.Accessors

class DefaultElement implements IElement {
	@Accessors val String name
	protected val connections = new LinkedHashSet<IElement>
	protected var (CircuitError)=>void onError = null

	override getConnections() { connections }
	
	new(String name) {
		this.name = name
	}
	
	def stackError(CircuitError error) {
		error.stack.add(name)
		if (onError !== null)
			onError.apply(error)
		else
			throw new RuntimeException('No error interceptor on element: ' + name)
	}
}