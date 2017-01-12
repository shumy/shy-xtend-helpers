package shy.xhelper.pipeline.io

interface IInbound<IN> {
	def void in(IN inData)
}