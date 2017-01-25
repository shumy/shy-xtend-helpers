package shy.xhelper.circuit

import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import java.util.regex.Matcher
import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.DefaultIO
import shy.xhelper.circuit.spec.DefaultPublisher

class XRouter<D> extends DefaultPublisher<D> {
	val (D)=>String matchValue
	
	@Accessors val Set<Route<D>> routes = new HashSet<Route<D>>
	
	new(String name, (D)=>String matchValue) {
		super(name)
		this.matchValue = matchValue 
	}
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		for (route: new HashSet(routes))
			route.publish(data)
		
		return this
	}
	
	def route(String regex) {
		val route = new Route('''«name»-R«routes.size»''', matchValue, regex)
		route.error[ stackError ]
		
		routes.add(route)
		return route
	}
}


class Route<D> extends DefaultIO<D> {
	val (D)=>String matchValue
	val Pattern pattern
	val Matcher matcher
	
	package new(String name, (D)=>String matchValue, String regex) {
		super(name)
		this.matchValue = matchValue
		this.pattern = Pattern.compile(regex)
		this.matcher = pattern.matcher('')
	}
	
	override publish(D data) {
		matcher.reset(matchValue.apply(data))
		try {
			if (matcher.matches)
				return super.publish(data)
		} catch(Throwable ex) {
			stackError(new CircuitError(ex.message, ex))
			return null
		}
	}
	
	@XAsynchronous
	def <T> extract((List<String>, D)=>T extractor) {
		val newExtractor = new DefaultIO<T>(name + '-E')
		newExtractor.error[ stackError ]
		
		then[ data |
			val params = new ArrayList<String>(matcher.groupCount)
			for(var i=1; i<=matcher.groupCount; i++)
				params.add(matcher.group(i))
			
			Async.run([ extractor.apply(params, data) ], [ newExtractor.publish(it) ], [
				newExtractor.stackError(new CircuitError(message, it))
			])
		]
		
		return newExtractor
	}
}
