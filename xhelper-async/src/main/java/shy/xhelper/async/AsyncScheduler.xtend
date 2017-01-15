package shy.xhelper.async

import java.util.concurrent.DelayQueue
import java.util.concurrent.Delayed
import java.util.concurrent.TimeUnit

class Task implements Delayed {
	public val () => void executor
	public val long atTime
	
	new(long delay, () => void executor) {
		this.executor = executor
		atTime = System.currentTimeMillis + delay
	}
	
	override getDelay(TimeUnit unit) {
		return atTime - System.currentTimeMillis
	}
	
	override compareTo(Delayed delayed) {
		val t = delayed as Task
		return (atTime - t.atTime) as int
	}
}

class AsyncScheduler {
	static val queue = new DelayQueue<Task>
	
	static def void schedule(() => void executor) {
		queue.add(new Task(0, executor))
	}
	
	static def void run() {
		while (true) {
			val task = queue.poll
			if (task != null)
				task.executor.apply
		}
	}
	
	static def void runFor(long seconds) {
		val long millis = 1000 * seconds
		val start = System.currentTimeMillis
		var end =  start
		
		while ( (end - start) < millis ) {
			val task = queue.poll
			if (task != null)
				task.executor.apply
			end = System.currentTimeMillis
		}
	}
}