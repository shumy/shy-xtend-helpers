package shy.testing.async

import java.util.HashMap
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import org.junit.Assert
import org.junit.Test
import shy.xhelper.pipeline.XMessage
import shy.xhelper.pipeline.XPipeline

import static shy.xhelper.async.Async.*

class TestAsync {
	
	@Test
	def void testSyncPipeline() {
		val res1 = new AtomicReference('')
		val res1_count = new AtomicInteger(0)
		val pipe1 = new XPipeline<Void, String, String>
		pipe1
			.filter[ data.contains('test') ]
			.map[ msg |
				new HashMap<String, String> => [
					put('x', 'value')
					put('y', msg.data)
				]
			]
			.forEach[ res1_count.andIncrement null ]
			.deliver[ res1.set('''«route» -> «data»''') ]
		
		//some system sends a message...
		pipe1.in(new XMessage(null, 'route', 'test-message'))
		pipe1.in(new XMessage(null, 'route', 'test-message'))
		Assert.assertEquals(2, res1_count.get)
		Assert.assertEquals('route -> {x=value, y=test-message}', res1.get)
		
		val res2 = new AtomicReference('')
		val pipe2 = new XPipeline<Void, String, String>
		pipe2
			.filter[ false ]
			.deliver[ res2.set('''«route» -> «data»''') ]
		
		//some system sends a message...
		pipe2.in(new XMessage(null, 'route', 'test-message'))
		Assert.assertEquals('', res2.get)
	}
	
	@Test
	def void testAsyncPipeline() {
		val res1 = new AtomicReference('')
		val res1_count = new AtomicInteger(0)
		val pipe1 = new XPipeline<Void, String, String>
		pipe1
			.filter[ result(data.contains('message')) ]
			.map[ msg |
				result(new HashMap<String, String> => [
					put('x', 'value')
					put('y', msg.data)
				])
			]
			.forEach[ res1_count.andIncrement result ]
			.deliver[ res1.set('''«route» -> «data»''') ]
		
		//some system sends a message...
		pipe1.in(new XMessage(null, 'route', 'test-message'))
		pipe1.in(new XMessage(null, 'route', 'test-message'))
		Assert.assertEquals(2, res1_count.get)
		Assert.assertEquals('route -> {x=value, y=test-message}', res1.get)
		
		val res2 = new AtomicReference('')
		val pipe2 = new XPipeline<Void, String, String>
		pipe2
			.filter[ result(false) ]
			.deliver[ res2.set('''«route» -> «data»''') ]
		
		//some system sends a message...
		pipe2.in(new XMessage(null, 'route', 'test-message'))
		Assert.assertEquals('', res2.get)
	}
	
	@Test
	def void testThrowErrorPipeline() {
		val res1 = new AtomicReference('')
		val pipe1 = new XPipeline<Void, String, String>
		pipe1
			.filter[ throw new RuntimeException('error') ]
			.deliver[ res1.set('''«route» -> «data»''') ]
			.error[ msg, error | res1.set('''«msg.route» -> «error.message»''') ]
		
		//some system sends a message...
		pipe1.in(new XMessage(null, 'route', 'error'))
		Assert.assertEquals('route -> error', res1.get)
	}
}