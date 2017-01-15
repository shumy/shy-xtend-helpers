package shy.xtesting.circuit

import shy.xhelper.data.XData
import shy.xhelper.ebean.json.gen.GenJson

@XData @GenJson
class Message {
	val Long id
	val String cmd
	
	val Integer seq
	
	override toString() '''(«id», «cmd», «seq»)'''
}