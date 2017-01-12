package shy.xhelper.pipeline

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class XMessage<CLIENT_INFO, DATA, OUT_DATA> {
	//DATA == Object -> for other processing parts it doesn't matter the DATA in format
	val XClient<CLIENT_INFO, Object, OUT_DATA> client
	val String route
	val DATA data
}