package shy.xhelper.ebean.json.converter

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import java.io.IOException
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.temporal.Temporal
import shy.xhelper.ebean.json.JsonDynamicProfile

class LocalDateTimeSerializer extends JsonSerializer<Temporal> {
	override serialize(Temporal value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		if (value instanceof LocalDate) {
			val json = value.format(JsonDynamicProfile.getFormater(LocalDate))
			gen.writeString(json)
			return
		}
		
		if (value instanceof LocalTime) {
			val json = value.format(JsonDynamicProfile.getFormater(LocalTime))
			gen.writeString(json)
			return
		}
		
		if (value instanceof LocalDateTime) {
			val json = value.format(JsonDynamicProfile.getFormater(LocalDateTime))
			gen.writeString(json)
			return
		}
	}
}

class LocalDateTimeDeserializer extends JsonDeserializer<Temporal> {
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		val json = jp.readValueAs(String)
		
		if (ctxt.contextualType.rawClass === LocalDate)
			return LocalDate.parse(json, JsonDynamicProfile.getFormater(LocalDate))
		
		if (ctxt.contextualType.rawClass === LocalTime)
			return LocalDate.parse(json, JsonDynamicProfile.getFormater(LocalTime))
		
		if (ctxt.contextualType.rawClass === LocalDateTime)
			return LocalDate.parse(json, JsonDynamicProfile.getFormater(LocalDateTime))
	}
}