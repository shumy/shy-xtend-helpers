package shy.xhelper.pipeline

import org.eclipse.xtend.lib.annotations.Accessors
import shy.xhelper.pipeline.io.IInbound
import shy.xhelper.pipeline.io.IOutbound

@Accessors
class XClient<CLIENT_INFO, IN_DATA, OUT_DATA> implements IInbound<IN_DATA>, IOutbound<OUT_DATA> {
	val CLIENT_INFO info
	
	override in(IN_DATA inData) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override out(OUT_DATA outData) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}