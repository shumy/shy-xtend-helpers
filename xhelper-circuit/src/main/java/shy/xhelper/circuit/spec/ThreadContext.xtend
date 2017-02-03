package shy.xhelper.circuit.spec

import java.util.Map
import java.util.HashMap

class ThreadContext {
	static val ctx = new ThreadLocal<Map<Class<?>, Object>> {
		override protected initialValue() { new HashMap<Class<?>, Object> }
	}
	
	static def void set(Class<?> type, Object value) { ctx.get.put(type, value) }
	static def <T> T get(Class<T> type) { ctx.get.get(type) as T }
	
	static def void flag(Class<?> type) { ctx.get.put(type, null) }
	static def boolean contains(Class<?> type) { ctx.get.containsKey(type) }
	
	static def void reset(Class<?> type) { ctx.get.remove(type) }
}