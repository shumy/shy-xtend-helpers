package shy.xhelper.pipeline

import org.slf4j.LoggerFactory
import shy.xhelper.async.Async
import shy.xhelper.async.XAsynchronous
import shy.xhelper.pipeline.io.IError
import shy.xhelper.pipeline.io.IInbound
import shy.xhelper.pipeline.io.PipelineException

class XPipeline<CLIENT_INFO, DATA, OUT_DATA> implements IInbound<XMessage<CLIENT_INFO, DATA, OUT_DATA>>, IError<CLIENT_INFO, DATA, OUT_DATA> {
	static val logger = LoggerFactory.getLogger(XPipeline)
	
	//var IError<CLIENT_INFO, OUT_DATA> parent = null //back propagate the error...
	var (XMessage<CLIENT_INFO, DATA, OUT_DATA>, Throwable)=>void onError = null
	var (XMessage<CLIENT_INFO, DATA, OUT_DATA>)=>void onDeliver = null
	
	package def void processError(XMessage<CLIENT_INFO, DATA, OUT_DATA> msg, Throwable error) {
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
		if (onDeliver === null)
			msg.processError(new PipelineException('No deliver handler!'))
		
		onDeliver.apply(msg)
	}
	
	@XAsynchronous
	def <T> map((XMessage<CLIENT_INFO, DATA, OUT_DATA>)=>T transform) {
		val newPipe = new XPipeline<CLIENT_INFO, T, OUT_DATA>
		
		error[ msg, error | newPipe.processError(new XMessage(msg.client, msg.route, null as T), error) ]
		deliver[ msg |
			Async.run([ transform.apply(msg) ], [
				val newMsg = new XMessage(msg.client, msg.route, it)
				newPipe.in(newMsg)
			], [ msg.processError(it) ])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def XPipeline<CLIENT_INFO, DATA, OUT_DATA> filter((XMessage<CLIENT_INFO, DATA, OUT_DATA>)=>boolean filter) {
		val newPipe = new XPipeline<CLIENT_INFO, DATA, OUT_DATA>
		
		error[ msg, error | newPipe.processError(msg, error) ]
		deliver[ msg |
			Async.run([ filter.apply(msg) ], [ if (it) newPipe.in(msg) ], [ msg.processError(it) ])
		]
		
		return newPipe
	}
	
	@XAsynchronous
	def XPipeline<CLIENT_INFO, DATA, OUT_DATA> forEach((XMessage<CLIENT_INFO, DATA, OUT_DATA>)=>Void process) {
		val newPipe = new XPipeline<CLIENT_INFO, DATA, OUT_DATA>
		
		error[ msg, error | newPipe.processError(msg, error) ]
		deliver[ msg |
			Async.run([ process.apply(msg) ], [ newPipe.in(msg) ], [ msg.processError(it) ])
		]
		
		return newPipe
	}
	
	def XPipeline<CLIENT_INFO, DATA, OUT_DATA> deliver((XMessage<CLIENT_INFO, DATA, OUT_DATA>)=>void onDeliver) {
		if (this.onDeliver !== null)
			throw new RuntimeException("Can't override the deliver. It was already set!")
		
		this.onDeliver = onDeliver
		return this
	}
}