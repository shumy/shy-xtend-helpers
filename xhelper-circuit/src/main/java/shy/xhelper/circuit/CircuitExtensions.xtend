package shy.xhelper.circuit

import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.IElement

class CircuitExtensions {
	static def <D> pipeline(IConnector<D> con, String name) {
		val next = new XPipeline<D>(name)
		con.connect(next)
		return next
	}
	
	static def <D> switcher(IConnector<D> con, String name) {
		val next = new XSwitcher<D>(name)
		con.connect(next)
		return next
	}
	
	static def <D> router(IConnector<D> con, String name, (D)=>String matchValue) {
		val next = new XRouter<D>(name, matchValue)
		con.connect(next)
		return next
	}
	
	static def String connectionTree(IElement elem) '''
		|-«elem.name»
		«elem.connectionTree(1)»
	'''
	
	private static def CharSequence connectionTree(IElement elem, int lvl) '''
		«FOR next: elem.connections»
			«printSpaces(lvl)»|-«next.name»
			«IF next.connections.size !== 0»
				«next.connectionTree(lvl + 1)»
			«ENDIF»
		«ENDFOR»
	'''
	
	private static def printSpaces(int spaces) {
		val sb = new StringBuilder
		for(i : 0 ..< spaces)
			sb.append('  ')
		
		return sb.toString
	}
}