package shy.xhelper.circuit

import java.util.LinkedHashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.spec.IElement

class XCircuit  {
	@Accessors val String name
	
	var boolean completed = false
	val staticElements = new LinkedHashMap<String, IElement>
	val dynamicElements = new LinkedHashMap<String, IElement>
	
	//TODO: input and output elements?
	
	package new(String name) {
		this.name = name
	}
	
	//close the static part of the circuit
	def void complete() { completed = true }
	
	def add(IElement elem) {
		val elemName = elem.elementName
		if (elements.containsKey(elemName))
			throw new RuntimeException('''Element already exist in circuit: { circuit: «name», element: «elemName» }''')
			
		elements.put(elemName, elem)
		return elemName
	}
	
	def get(String elementName) {
		val elem = elements.get(elementName)
		if (elements.containsKey(elem.name))
			throw new RuntimeException('''No element available in circuit: { circuit: «name», element: «elementName» }''')
		
		return elem
	}
	
	def void remove(String elementName) {
		if (!completed)
			throw new RuntimeException('''Can not remove element from circuit before completion: { circuit: «name», element: «elementName» }''')
		
		dynamicElements.remove(elementName)
	}
	
	private def String elementName(IElement elem) {
		if (completed) '''«elem.name»(«UUID.randomUUID.toString»)''' else elem.name
	}
	
	private def elements() {
		if (completed) dynamicElements else staticElements
	}
	
	override toString() '''
		«name»:
		  static:       [«FOR key: staticElements.keySet SEPARATOR ', '»«key»«ENDFOR»]
		  dynamic:      [«FOR key: dynamicElements.keySet SEPARATOR ', '»«key»«ENDFOR»]
	'''
}