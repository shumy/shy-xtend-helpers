package shy.xhelper.ebean.json

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.databind.ser.std.StdSerializer
import java.io.IOException
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class LocalDateTimeSerializer extends StdSerializer<LocalDateTime> {
	new() { super(LocalDateTime) }
	
	override serialize(LocalDateTime value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		gen.writeString(value.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
	}
}

class LocalDateTimeDeserializer extends StdDeserializer<LocalDateTime> {
	new() { super(LocalDateTime) }
	
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		LocalDateTime.parse(jp.readValueAs(String))
	}
}