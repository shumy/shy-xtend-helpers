package shy.xhelper.pipeline.io

interface IOutbound<OUT> {
	def void out(OUT outData)
}