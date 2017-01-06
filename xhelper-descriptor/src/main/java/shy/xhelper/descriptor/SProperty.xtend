package shy.xhelper.descriptor

class SProperty {
	public val SType type
	public val String name
	public val Boolean opt
	
	new(String name, SType type) { this(name, type, null) }
	new(String name, SType type, Boolean isOptional) {
		this.name = name
		this.type = type
		this.opt = isOptional
	}
}