package shy.xhelper.circuit

import java.util.concurrent.ConcurrentHashMap

class CircuitRegistry {
	static val ctx = new ThreadLocal<XCircuit>
	static val circuits = new ConcurrentHashMap<String, XCircuit>
	
	static def ctx() { ctx.get }
	
	static def void select(String circuitName, (XCircuit)=>void runner) {
		val circuit = circuits.get(circuitName)
		if (circuit === null)
			throw new RuntimeException('''No circuit available: { circuit: «circuitName» }''')
			
		ctx.set(circuit)
			runner.apply(circuit)
		ctx.set(null)
	}
	
	static def create(String circuitName, (XCircuit)=>void builder) {
		if (circuits.containsKey(circuitName))
			throw new RuntimeException('''Already existent circuit: { circuit: «circuitName» }''')
		
		val circuit = new XCircuit(circuitName)
		ctx.set(circuit)
			circuits.put(circuitName, circuit)
			builder.apply(circuit)
			circuit.complete
		ctx.set(null)
		
		return circuit
	}
}