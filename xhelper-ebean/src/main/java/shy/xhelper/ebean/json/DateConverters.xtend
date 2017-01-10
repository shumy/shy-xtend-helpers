package shy.xhelper.ebean.json

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.databind.ser.std.StdSerializer
import java.io.IOException
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class LocalDateSerializer extends StdSerializer<LocalDate> {
	new() { super(LocalDate) }
	
	override serialize(LocalDate value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		gen.writeString(value.format(DateTimeFormatter.ISO_LOCAL_DATE))
	}
}

class LocalDateDeserializer extends StdDeserializer<LocalDate> {
	new() { super(LocalDate) }
	
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		LocalDate.parse(jp.readValueAs(String))
	}
}