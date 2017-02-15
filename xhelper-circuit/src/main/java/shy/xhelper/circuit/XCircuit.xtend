package shy.xhelper.circuit

import java.util.LinkedHashMap
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.IElement
import shy.xhelper.circuit.spec.ThreadContext
import shy.xhelper.circuit.spec.defaults.Element
import shy.xhelper.circuit.spec.defaults.ProxyElement

class XCircuit  {
	@Accessors val String name
	
	val elements = new LinkedHashMap<String, IElement>
	//TODO: core and plugin elements ?
	//TODO: input and output elements ?
	
	new(String name, (XCircuit)=>void builder) {
		this.name = name
		ThreadContext.set(XCircuit, this)
			builder.apply(this)
		ThreadContext.reset(XCircuit)
	}
	
	def void addElement(String elementName, IElement elem) {
		if (elements.containsKey(elementName))
			throw new RuntimeException('''Element already exist in circuit: { circuit: «name», element: «elementName» }''')
			
		elements.put(elementName, elem)
	}
	
	def getElement(String elementName) {
		val elem = elements.get(elementName)
		if (elements.containsKey(elem.name))
			throw new RuntimeException('''No element available in circuit: { circuit: «name», element: «elementName» }''')
		
		return elem
	}
	
	def <D, T extends IConnector<D>> void plugin(String position, (T)=>IConnector<D> pluginFun) {
		if (ThreadContext.contains(ProxyElement))
			throw new RuntimeException('''Insert plugins one at a time: { circuit: «name», position: «position» }''')
			
		val elem = elements.get(position) as Element<D>
		if (elem === null)
			throw new RuntimeException('''No element at position: { circuit: «name», position: «position» }''')
		
		ThreadContext.set(ProxyElement, elem.proxy)
			val end = pluginFun.apply(elem as T) as Element<D>
		ThreadContext.reset(ProxyElement)
		
		if (end === null)
			throw new RuntimeException('''Plugin function returned null: { circuit: «name», position: «position» }''')
		
		if (end === elem)
			throw new RuntimeException('''Plugin function returned the same element: { circuit: «name», position: «position» }''')
		
		elem.proxy.complete(end.proxy)
	}
	
	override toString() '''
		«name»:
		  static:       [«FOR key: elements.keySet SEPARATOR ', '»«key»«ENDFOR»]
	'''
}