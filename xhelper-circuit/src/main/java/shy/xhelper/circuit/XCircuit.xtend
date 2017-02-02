package shy.xhelper.circuit

import java.util.LinkedHashMap
import java.util.UUID
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.spec.IElement
import shy.xhelper.circuit.spec.IPublisherConnector
import shy.xhelper.circuit.spec.IPublisher

class XCircuit  {
	@Accessors val String name
	
	var boolean completed = false
	val staticElements = new LinkedHashMap<String, IElement>
	val dynamicElements = new LinkedHashMap<String, IElement>
	
	//TODO: input and output elements?
	
	package new(String name) {
		this.name = name
	}
	
	def String elementPostfix() {
		if (completed) '''(«UUID.randomUUID.toString»)''' else ''
	}
	
	def void addElement(IElement elem) {
		if (elements.containsKey(elem.name))
			throw new RuntimeException('''Element already exist in circuit: { circuit: «name», element: «elem.name» }''')
			
		elements.put(elem.name, elem)
	}
	
	def getElement(String elementName) {
		val elem = elements.get(elementName)
		if (elements.containsKey(elem.name))
			throw new RuntimeException('''No element available in circuit: { circuit: «name», element: «elementName» }''')
		
		return elem
	}
	
	def void removeElement(String elementName) {
		if (!completed)
			throw new RuntimeException('''Can not remove element from circuit before completion: { circuit: «name», element: «elementName» }''')
		
		dynamicElements.remove(elementName)
	}
	
	//close the static part of the circuit
	def void complete() { completed = true }
	
	def <D> void addPlugin(String position, IPublisherConnector<D> plugin) {
		val elem = staticElements.get(position) as IPublisher<D>
		if (elem === null)
			throw new RuntimeException('''No element at position: { circuit: «name», position: «position» }''')
		
		elem.proxy.connect(plugin)
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