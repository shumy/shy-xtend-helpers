package shy.testing.circuit

import org.junit.Test
import shy.xhelper.circuit.XRouter
import shy.xtesting.circuit.Message
import org.junit.Assert

class TestRouter {
	
	def void publishMesages(XRouter<Message> it) {
		publish(new Message(1L, '/x/y', 1))
		publish(new Message(2L, '/y/10', 1))
		publish(new Message(3L, 'no path', 1)) //no route
	}
	
	@Test
	def void testRouter() {
		val sb = new StringBuilder
		
		val router = new XRouter<Message>('r1')[ cmd ] => [
			route('/x/y')
				.then[ sb.append('''/x/y - «toString»«'\n'»''') ]
			
			route('/y/(.*)')
				.extract[ params, data | sb.append('''/y/(.*) - params - «params.toString»«'\n'»''') data ]
				.then[ sb.append('''/y/(.*) - «toString»«'\n'»''') ]
			
			//match paths and extract path...
			route('(/.*)')
				.extract[ params, data | sb.append('''.* - params - «params.toString»«'\n'»''') data ]
				.then[ sb.append('''.* - «toString»«'\n'»''') ]
		]
		
		router.publishMesages
		println(sb.toString)
		
		Assert.assertEquals(3, router.routes.size)
		Assert.assertEquals('''
			/x/y - (1, /x/y, 1)
			.* - params - [/x/y]
			.* - (1, /x/y, 1)
			/y/(.*) - params - [10]
			/y/(.*) - (2, /y/10, 1)
			.* - params - [/y/10]
			.* - (2, /y/10, 1)
		'''.toString, sb.toString)
	}
}