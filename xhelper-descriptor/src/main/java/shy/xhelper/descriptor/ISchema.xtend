package shy.xhelper.descriptor

import java.util.List

interface ISchema {
	def List<SProperty> getProperties()
	def List<SMethod> getMethods()
}