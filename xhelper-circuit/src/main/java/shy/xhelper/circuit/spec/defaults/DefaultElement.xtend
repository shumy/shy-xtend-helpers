package shy.xhelper.circuit.spec.defaults

import java.util.LinkedHashSet
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.XCircuit
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IElement
import shy.xhelper.circuit.spec.PluginProxy
import shy.xhelper.circuit.spec.ThreadContext

class DefaultElement implements IElement {
	@Accessors val String name
	@Accessors val proxy = new PluginProxy(this)
	
	protected val connections = new LinkedHashSet<IElement>
	
	override getConnections() { connections }
	
	protected var (CircuitError)=>void onError = null
	protected var XCircuit circuit = null
	
	new(String name) {
		circuit = ThreadContext.get(XCircuit)
		this.name = if (circuit !== null) name else '''«name»(«UUID.randomUUID.toString»)'''
		
		if (circuit !== null)
			circuit.addElement(this)
	}
	
	override stackError(CircuitError error) {
		proxy.stackError(error)
	}
	
	def void addConnection(IElement publisher) {
		if (!ThreadContext.contains(PluginProxy))
			connections.add(publisher)
	}
}