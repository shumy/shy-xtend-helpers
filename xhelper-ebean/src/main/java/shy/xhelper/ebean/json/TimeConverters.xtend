package shy.xhelper.ebean.json

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.databind.ser.std.StdSerializer
import java.io.IOException
import java.time.LocalTime
import java.time.format.DateTimeFormatter

class LocalTimeSerializer extends StdSerializer<LocalTime> {
	new() { super(LocalTime) }
	
	override serialize(LocalTime value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		gen.writeString(value.format(DateTimeFormatter.ISO_LOCAL_TIME))
	}
}

class LocalTimeDeserializer extends StdDeserializer<LocalTime> {
	new() { super(LocalTime) }
	
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		LocalTime.parse(jp.readValueAs(String))
	}
}