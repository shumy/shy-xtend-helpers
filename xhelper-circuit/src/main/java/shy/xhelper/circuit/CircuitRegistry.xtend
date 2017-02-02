package shy.xhelper.circuit

import java.util.concurrent.ConcurrentHashMap

class CircuitRegistry {
	static val ctx = new ThreadLocal<XCircuit>
	static val circuits = new ConcurrentHashMap<String, XCircuit>
	
	static def ctx() {
		val circuit = ctx.get
		if (circuit === null)
			throw new RuntimeException('No circuit available in context!')
			
		return circuit
	}
	
	static def select(String circuitName) {
		val circuit = circuits.get(circuitName)
		if (circuit === null)
			throw new RuntimeException('''No circuit available: { circuit: «circuitName» }''')
			
		ctx.set(circuit)
		return circuit
	}
	
	static def create(String circuitName) {
		if (circuits.containsKey(circuitName))
			throw new RuntimeException('''Already existent circuit: { circuit: «circuitName» }''')
		
		val circuit = new XCircuit(circuitName)
		circuits.put(circuitName, circuit)
		ctx.set(circuit)
		
		return circuit
	}
}