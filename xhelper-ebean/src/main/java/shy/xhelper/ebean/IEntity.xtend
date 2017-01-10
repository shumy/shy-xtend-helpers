package shy.xhelper.ebean

import com.fasterxml.jackson.databind.ObjectMapper

interface IEntity {
	static final val jMapper = new ObjectMapper
	
	def Long getId()
}