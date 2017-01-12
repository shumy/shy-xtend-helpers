package shy.xhelper.pipeline.io

import shy.xhelper.pipeline.XMessage

public interface IError<CLIENT_INFO, DATA, OUT_DATA> {
	def void error((XMessage<CLIENT_INFO, DATA, OUT_DATA>, Throwable)=>void onError)
}