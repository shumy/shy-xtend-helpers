package shy.xhelper.circuit.spec

import org.eclipse.xtend.lib.annotations.Accessors

class DefaultElement {
	@Accessors val String name
	protected var (Error)=>void onError = null
	
	new(String name) { this.name = name }
	
	def stackError(Error error) {
		error.stack.add(name)
		if (onError !== null)
			onError.apply(error)
		else
			throw new RuntimeException('No error interceptor on element: ' + name)
	}
}