package shy.xhelper.ebean.json.converter

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import java.io.IOException

class RefSerializer extends JsonSerializer<Object> {
	
	override serialize(Object value, JsonGenerator gen, SerializerProvider serializers) throws IOException, JsonProcessingException {
		try {
			val meth = value.class.getMethod('getId')
			val id = meth.invoke(value) as Long
			gen.writeNumber(id)
		} catch(Throwable ex) {
			println('No getId!')
		}
	}
	
	override isEmpty(SerializerProvider provider, Object value) {
		if (value === null) return true
		
		try {
			value.class.getMethod('getId')
			return false
		} catch(Throwable ex) {
			return true
		}
	}
}

class RefDeserializer extends JsonDeserializer<Object> {
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		 
	}
}