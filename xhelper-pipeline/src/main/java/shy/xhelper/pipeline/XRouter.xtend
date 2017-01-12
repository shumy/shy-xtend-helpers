package shy.xhelper.pipeline

import java.util.Collections
import java.util.HashMap
import java.util.Map
import shy.xhelper.pipeline.io.DefaultErrorImpl
import shy.xhelper.pipeline.io.IInbound
import shy.xhelper.pipeline.io.PipelineException

class XRouter<CLIENT_INFO, DATA, OUT_DATA> extends DefaultErrorImpl<CLIENT_INFO, DATA, OUT_DATA> implements IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>> {
	val routes = new HashMap<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>
	val routesView = Collections.unmodifiableMap(routes)
	
	var (XMessage<CLIENT_INFO, DATA, OUT_DATA>, Map<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>)=>void onRoute = null
	
	override in(XMessage<CLIENT_INFO, DATA, OUT_DATA> msg) {
		if (onRoute !== null)
			try {
				onRoute.apply(msg, routesView)
			} catch(Throwable error) {
				msg.processError(error)
			}
		else {
			val route = routes.get(msg.route)
			if (route === null)
				msg.processError(new PipelineException('No route to: ' + msg.route))
		}
	}
	
	def addRoute(String address, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>> route) {
		if (routes.containsKey(address))
			throw new RuntimeException('Route address already exists: ' + address)
		
		routes.put(address, route)
		return this
	}
	
	def void routing((XMessage<CLIENT_INFO, DATA, OUT_DATA>, Map<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>)=>void onRoute) {
		if (this.onRoute !== null)
			throw new RuntimeException("Can't override Routing function. It was already set!")
			
		this.onRoute = onRoute
	}
}