package shy.xhelper.ebean.json.converter

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import java.io.IOException

class CollectionSerializer extends JsonSerializer<Iterable<?>> {
	override serialize(Iterable<?> value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		sp.defaultSerializeValue(value, gen)
	}
	
	override isEmpty(SerializerProvider provider, Iterable<?> value) {
		true
	}
}

class CollectionDeserializer extends JsonDeserializer<Iterable<?>> {
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		 
	}
}