package shy.testing.circuit

import java.util.HashMap
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import org.junit.Assert
import org.junit.Test
import shy.xhelper.circuit.CircuitRegistry
import shy.xhelper.circuit.XPipeline
import shy.xtesting.circuit.Message

import static shy.xhelper.async.Async.*

class TestPipeline {
	
	@Test
	def void testSyncPipeline() {
		val res1 = new AtomicReference('')
		val res1_count = new AtomicInteger(0)
		val pipe1 = new XPipeline<Message>('P1')
		pipe1
			.filter[ cmd.contains('test') ]
			.map[ msg |
				new HashMap<String, Integer> => [
					put('x', 10)
					put('y', msg.seq)
				]
			]
			.forEach[ res1_count.andIncrement null ]
			.then[ res1.set('''{x:«get('x')», y:«get('y')»}''') ]
		
		//some system sends a message...
		pipe1.publish(new Message(1L, 'test-message', 20))
		pipe1.publish(new Message(2L, 'test-message', 30))
		Assert.assertEquals(2, res1_count.get)
		Assert.assertEquals('{x:10, y:30}', res1.get)
		
		val res2 = new AtomicReference('')
		val pipe2 = new XPipeline<Message>('P2')
		pipe2
			.filter[ false ]
			.then[ res2.set('''«cmd» -> «seq»''') ]
		
		//some system sends a message...
		pipe2.publish(new Message(1L, 'test-message', 10))
		Assert.assertEquals('', res2.get)
	}
	
	@Test
	def void testAsyncPipeline() {
		CircuitRegistry.create('testAsyncPipeline')
		
		val res1 = new AtomicReference('')
		val res1_count = new AtomicInteger(0)
		val pipe1 = new XPipeline<Message>('P1')
		pipe1
			.filter[ yield(cmd.contains('message')) ]
			.map[ msg |
				yield(new HashMap<String, Integer> => [
					put('x', 10)
					put('y', msg.seq)
				])
			]
			.forEach[ res1_count.andIncrement yield ]
			.then[ res1.set('''{x:«get('x')», y:«get('y')»}''')  ]
		
		//some system sends a message...
		pipe1.publish(new Message(1L, 'test-message', 20))
		pipe1.publish(new Message(2L, 'test-message', 30))
		Assert.assertEquals(2, res1_count.get)
		Assert.assertEquals('{x:10, y:30}', res1.get)
		
		val res2 = new AtomicReference('')
		val pipe2 = new XPipeline<Message>('P2')
		pipe2
			.filter[ yield(false) ]
			.then[ res2.set('''«cmd» -> «seq»''') ]
		
		//some system sends a message...
		pipe2.publish(new Message(1L, 'test-message', 10))
		Assert.assertEquals('', res2.get)
	}
	
	@Test
	def void testThrowErrorPipeline() {
		val resSync = new AtomicReference('')
		val pipeSync = new XPipeline<Message>('P1')
		pipeSync
			.filter[ throw new RuntimeException('filter-error') ]
			.then[ resSync.set('''«cmd» -> «seq»''') ]
		
		//some system sends a message...
		pipeSync
			.error[ resSync.set('''error -> «msg»''') ]
			.publish(new Message(1L, 'route', 10))
		Assert.assertEquals('error -> filter-error', resSync.get)
		
		val resAsync = new AtomicReference('')
		val pipeAsync = new XPipeline<Message>('P2')
		pipeAsync
			.filter[ yield(new RuntimeException('filter-error')) true ]
			.then[ resAsync.set('''«cmd» -> «seq»''') ]
		
		//some system sends a message...
		pipeAsync
			.error[ resAsync.set('''error -> «msg»''') ]
			.publish(new Message(1L, 'route', 10))
		Assert.assertEquals('error -> filter-error', resAsync.get)
	}
}