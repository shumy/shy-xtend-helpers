package shy.testing.circuit

import org.junit.Assert
import org.junit.Test
import shy.xhelper.circuit.XCircuit
import shy.xhelper.circuit.XPipeline
import shy.xtesting.circuit.Message

import static extension shy.xhelper.circuit.CircuitExtensions.*

class TestCircuit {
	
	@Test
	def void simpleCircuit() {
		val sb = new StringBuilder
		new XCircuit('simpleCircuit')[
			
			// main circuit
			val pipe = new XPipeline<String>('P1')
			pipe
				.map[ Message.fromJson(it) ]
				//plugin inserted here (in serie)
				.switcher('S1') => [
					when[ cmd == 'ok' ].then[ sb.append(it) ]
					when[ cmd == 'error' ].then[ throw new RuntimeException('error') ]
					when[ cmd == 'filtered' ].then[ sb.append(it) ]
				]
			
			// plugins
			plugin('P1-M', [ XPipeline<Message> it |
				//add filter as a plugin...
				filter[
					if (cmd == 'filter-error')
						throw new RuntimeException('filter-error')
						
					cmd != 'filtered'
				]
			])
			
			//plugins are not part of the tree
			Assert.assertEquals('''
			|-P1
			  |-P1-M
			    |-S1
			      |-S1-B0
			      |-S1-B1
			      |-S1-B2
			'''.toString, pipe.connectionTree)
			
			//TODO: use circuit instead to process messages...
			pipe => [
				error[ sb.append('''(«msg», «stack»)''') ]
				publish('{"id":1,"cmd":"ok","seq":1}')
				publish('{"id":1,"cmd":"error","seq":2}')
				publish('{"id":1,"cmd":"filtered","seq":3}')
				publish('{"id":1,"cmd":"ok","seq":4}')
				publish('{"id":1,"cmd":"filter-error","seq":5}')
			]
			
			Assert.assertEquals('(1, ok, 1)(error, [S1-B1, S1, P1-M, P1])(1, ok, 4)(filter-error, [P1-M-F, P1-M, P1])', sb.toString)
			println(it)
		]
	}
}