package shy.xhelper.circuit.spec.defaults

import java.util.LinkedHashSet
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.XCircuit
import shy.xhelper.circuit.spec.IElement
import shy.xhelper.circuit.spec.ThreadContext

abstract class Element implements IElement {
	@Accessors val String name
	
	protected var XCircuit circuit = null
	protected val connections = new LinkedHashSet<IElement>
	
	override getConnections() { connections }
	
	new(String name) {
		circuit = ThreadContext.get(XCircuit)
		this.name = if (circuit !== null) name else '''«name»(«UUID.randomUUID.toString»)'''
		
		if (circuit !== null)
			circuit.addElement(this)
	}
	
	def void addConnection(IElement publisher) {
		if (!ThreadContext.contains(ProxyElement))
			connections.add(publisher)
	}
}