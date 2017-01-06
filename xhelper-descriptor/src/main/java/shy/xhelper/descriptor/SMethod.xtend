package shy.xhelper.descriptor

import java.util.List

class SMethod {
	public val String name
	public val SType retType
	public val List<SProperty> params
	
	new(String name, SType returnType, List<SProperty> params) {
		this.name = name
		this.retType = returnType
		this.params = params
	}
}