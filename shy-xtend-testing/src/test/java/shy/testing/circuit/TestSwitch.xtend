package shy.testing.circuit

import java.util.HashMap
import org.junit.Assert
import org.junit.Test
import shy.xhelper.circuit.XSwitcher
import shy.xhelper.circuit.spec.IConnector
import shy.xtesting.circuit.Message

class TestSwitch {
	
	def void publishMesages(XSwitcher<Message> it) {
		//init streams...
		publish(new Message(1L, 'init', 1))
		publish(new Message(2L, 'init', 2))
		
			//send data streams...
			publish(new Message(1L, 'nxt', 3))
			publish(new Message(2L, 'nxt', 4))
			publish(new Message(1L, 'nxt', 5))
		
		//complete stream 1
		publish(new Message(1L, 'cpl', 6))
			publish(new Message(1L, 'nxt', 7)) //stream is ended, should not appear!
	}
	
	@Test
	def void testStreamController() {
		val sb = new StringBuilder
		
		val streams = new HashMap<Long, IConnector<Message>>
		val switcher = new XSwitcher<Message>('s1') => [
			when[ cmd == 'init' ].then[ msg |
				val branch = when[ cmd == 'nxt' && id === msg.id ].then[
					sb.append('''stream - «msg.id» «it»«'\n'»''')
				]
				
				sb.append('''init - «msg» at «branch.name»«'\n'»''')
				streams.put(msg.id, branch)
			]
			when[ cmd == 'cpl' ].then[ msg | 
				val branch = streams.get(msg.id)
				sb.append('''complete - «msg» at «branch.name»«'\n'»''')
				branches.remove(branch)
			]
		]
		
		switcher.publishMesages
		
		Assert.assertEquals(3, switcher.branches.size)
		Assert.assertEquals('''
			init - (1, init, 1) at s1-B2
			init - (2, init, 2) at s1-B3
			stream - 1 (1, nxt, 3)
			stream - 2 (2, nxt, 4)
			stream - 1 (1, nxt, 5)
			complete - (1, cpl, 6) at s1-B2
		'''.toString, sb.toString)
	}
	
	/*@Test
	def void testAsyncStreamController() {
		val controlSb = new StringBuilder
		val dataList = new ArrayList<Message>
		
		val streams = new HashMap<Long, IConnector<Message>>
		val switcher = new XSwitcher<Message>('s1') => [
			when[ result(cmd == 'init') ].then[ msg |
				val branch = when[ task[ cmd == 'nxt' && id === msg.id ] ].then[
					dataList.add(it)
				]
				
				controlSb.append('''init - «msg» at «branch.name»«'\n'»''')
				streams.put(msg.id, branch)
			]
			when[ result(cmd == 'cpl') ].then[ msg | 
				val branch = streams.get(msg.id)
				controlSb.append('''complete - «msg» at «branch.name»«'\n'»''')
				branches.remove(branch)
			]
		]
		
		AsyncScheduler.schedule[ switcher.publishMesages ]
		AsyncScheduler.runFor(1)
		
		Assert.assertEquals(3, switcher.branches.size)
		Assert.assertEquals('''
			init - (1, init, 1) at s1-B2
			init - (2, init, 2) at s1-B3
			complete - (1, cpl, 6) at s1-B2
		'''.toString, controlSb.toString)
		Assert.assertEquals('[(1, nxt, 3), (2, nxt, 4), (1, nxt, 5)]'.toString, dataList.sortInplaceBy[ seq ].toString)
	}*/
	
}