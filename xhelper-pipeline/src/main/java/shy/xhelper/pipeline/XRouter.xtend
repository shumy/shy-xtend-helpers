package shy.xhelper.pipeline

import java.util.Collections
import java.util.HashMap
import java.util.Map
import org.slf4j.LoggerFactory
import shy.xhelper.pipeline.io.IError
import shy.xhelper.pipeline.io.IInbound
import shy.xhelper.pipeline.io.PipelineException

class XRouter<CLIENT_INFO, DATA, OUT_DATA> implements IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>, IError<CLIENT_INFO, DATA, OUT_DATA> {
	static val logger = LoggerFactory.getLogger(XRouter)
	
	val routes = new HashMap<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>
	val routesView = Collections.unmodifiableMap(routes)
	
	var (XMessage<CLIENT_INFO, DATA, OUT_DATA>, Throwable)=>void onError = null
	var (XMessage<CLIENT_INFO, DATA, OUT_DATA>, Map<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>)=>void onRoute = null
	
	def void processError(XMessage<CLIENT_INFO, DATA, OUT_DATA> msg, Throwable error) {
		logger.error(error.message)
		if (onError !== null)
			onError.apply(msg, error)
		else
			throw error
	}
	
	override void error((XMessage<CLIENT_INFO, DATA, OUT_DATA>, Throwable)=>void onError) {
		this.onError = onError
	}
	
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
	
	def void addRoute(String name, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>> route) {
		routes.put(name, route)
	}
	
	def void routing((XMessage<CLIENT_INFO, DATA, OUT_DATA>, Map<String, IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>>)=>void onRoute) {
		this.onRoute = onRoute
	}
}