package shy.testing.circuit

import org.junit.Test
import shy.xhelper.circuit.XPipeline
import shy.xhelper.circuit.XSwitch
import shy.xtesting.circuit.Message
import org.junit.Assert

class TestCircuit {
	
	@Test
	def void simpleCircuit() {
		val sb = new StringBuilder
		
		val pipe = new XPipeline<String>('P1') => [
			error[ sb.append(it) ]
			
			map[ Message.fromJson(it) ]
			.filter[ cmd != 'filtered' ]
			.connect(new XSwitch<Message>('S1') => [
				when[ cmd == 'ok' ].then[ sb.append(it) ]
				when[ cmd == 'error' ].then[ throw new RuntimeException('error') ]
				when[ cmd == 'filtered' ].then[ sb.append(it) ]
			])
		]
		
		pipe.publish('{"id":1,"cmd":"ok","seq":1}')
		pipe.publish('{"id":1,"cmd":"error","seq":2}')
		pipe.publish('{"id":1,"cmd":"filtered","seq":3}')
		pipe.publish('{"id":2,"cmd":"ok","seq":4}')
		
		Assert.assertEquals('(1, ok, 1){ "msg":"error", "stack":"[S1-B1, S1, P1-M-F, P1-M, P1]", "type":"RuntimeException" }(2, ok, 4)', sb.toString)
	}
}