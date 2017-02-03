package shy.xhelper.circuit

import java.util.ArrayList
import java.util.LinkedHashSet
import java.util.List
import java.util.regex.Matcher
import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.circuit.spec.CircuitError
import shy.xhelper.circuit.spec.IConnector
import shy.xhelper.circuit.spec.defaults.ProxyElement

@FinalFieldsConstructor
class XRouter<D> extends ProxyElement<D> {
	val routes = new LinkedHashSet<Route<D>>
	
	val (D)=>String matchValue
	var (D)=>void noRoute = null
	
	def Iterable<Route<D>> getRoutes() { routes }
	
	def void remove(IConnector<D> route) {
		routes.remove(route)
		connections.remove(route)
	}
	
	override publish(D data) {
		//a copy of the set is used to support concurrent modifications
		var hasRoute = false
		for (route: new LinkedHashSet(routes))
			hasRoute = route.tryPublish(data)
		
		if (!hasRoute && noRoute !== null)
			noRoute.apply(data)
		
		return this
	}
	
	def route(String regex) {
		val route = new Route('''«name»-R«routes.size»''', matchValue, regex)
		addConnection(route)
		
		route.error[ stackError ]
		routes.add(route)
		return route
	}
	
	def noRoute((D)=>void noRoute) {
		this.noRoute = noRoute
	}
}


class Route<D> extends ProxyElement<D> {
	val (D)=>String matchValue
	val Pattern pattern
	val Matcher matcher
	
	package new(String name, (D)=>String matchValue, String regex) {
		super(name)
		this.matchValue = matchValue
		this.pattern = Pattern.compile(regex)
		this.matcher = pattern.matcher('')
	}
	
	package def tryPublish(D data) {
		matcher.reset(matchValue.apply(data))
		try {
			if (matcher.matches) {
				publish(data)
				return true
			}
		} catch(Throwable ex) {
			stackError(new CircuitError(ex))
		}
		
		return false
	}
	
	@XAsynchronous
	def <T> IConnector<T> extract((List<String>, D)=>T extractor) {
		val newExtractor = new ProxyElement<T>(name + '-E')
		addConnection(newExtractor)
		
		newExtractor.error[ stackError ]
		then[ data |
			val params = new ArrayList<String>(matcher.groupCount)
			for(var i=1; i<=matcher.groupCount; i++)
				params.add(matcher.group(i))
			
			Async.run([ extractor.apply(params, data) ], [ newExtractor.publish(it) ], [
				newExtractor.stackError(new CircuitError(it))
			])
		]
		
		return newExtractor
	}
}
