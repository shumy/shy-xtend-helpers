package shy.xhelper.pipeline.io

import org.slf4j.LoggerFactory
import shy.xhelper.pipeline.XMessage

class DefaultErrorImpl<CLIENT_INFO, DATA, OUT_DATA> implements IError<CLIENT_INFO, DATA, OUT_DATA> {
	static val logger = LoggerFactory.getLogger(DefaultErrorImpl)
	
	private var (XMessage<CLIENT_INFO, DATA, OUT_DATA>, Throwable)=>void onError = null
	
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
}