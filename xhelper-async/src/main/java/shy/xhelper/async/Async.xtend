package shy.xhelper.async

import java.util.Stack

class Async {
	static val zone = new ThreadLocal<Stack<AsyncResult<?>>> {
		override protected initialValue() { new Stack<AsyncResult<?>> }
	}
	
	private static def AsyncResult<Object> peek() {
		val ctx = zone.get.peek as AsyncResult<Object>
		if (ctx === null)
			throw new AsyncException('No async context available!')
		
		return ctx
	}
	
	private static def <T> void processResult(T value, (T)=>void onResult, (Throwable)=>void onError) {
		if (value instanceof Throwable)
			onError.apply(value)
		else
			onResult.apply(value)
	}
	
	//mark the context as async...
	static def Void async() {
		peek.isAsync = true
		return null
	}
	
	//mark the context as async and result available...
	static def <T> T yield() {
		peek => [ isAsync = true result = null ]
		return null
	}
	
	//mark the context as async and set the result...
	static def <T> T yield(T aResult) {
		peek => [ isAsync = true result = aResult ]
		null as T
	}
	
	static def <T> T task(()=>T task) {
		val asyncRes = peek
		asyncRes.isAsync = true
		
		new Thread[
			try {
				val res = task.apply
				AsyncScheduler.schedule[ asyncRes.result = res ]
			} catch(Throwable ex) {
				AsyncScheduler.schedule[ asyncRes.result = ex ]
			}
		].start
		
		null as T
	}
	
	//run an enclosure function with async context available... 
	static def <T> void run(()=>T task, (T)=>void onResult, (Throwable)=>void onError) {
		zone.get.push(new AsyncResult)
			try {
				val T value = task.apply
				val ctx = zone.get.peek as AsyncResult<T>
				if (ctx.isAsync) ctx.onResult[
					processResult(onResult, onError)
				] else
					value.processResult(onResult, onError)
			} catch(Throwable ex) {
				onError.apply(ex)
			} finally {
				zone.get.pop
			}
	}
}

class AsyncResult<T> {
	public var boolean isAsync = false
	
	var boolean hasResult = false
	var T result = null
	var (T)=>void onResult = null
	
	def void setResult(T result) {
		this.hasResult = true
		this.result = result
		
		onResult?.apply(result)
	}
	
	def void onResult((T)=>void onResult) {
		this.onResult = onResult
		if (hasResult)
			onResult.apply(result)
	}
}

class AsyncException extends RuntimeException {
	new(String msg) { super(msg) }
}