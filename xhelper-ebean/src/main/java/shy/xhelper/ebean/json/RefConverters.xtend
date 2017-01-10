package shy.xhelper.ebean.json

import com.fasterxml.jackson.databind.ser.std.StdSerializer
import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.SerializerProvider
import java.io.IOException
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.core.JsonProcessingException
import shy.xhelper.ebean.IEntity

class EntityRefSerializer extends StdSerializer<IEntity> {
	new() { super(IEntity) }
	
	override serialize(IEntity value, JsonGenerator gen, SerializerProvider sp) throws IOException {
		gen.writeRawValue('''{"id":«value.id»,"type":"ref","to":"«value.class.name»"}''')
	}
}

/*class EntityRefDeserializer extends StdDeserializer<BaseModel> {
	new() { super(BaseModel) }
	
	override deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		jp.readV
		//ctxt.
		//BaseModel.parse(jp.readValueAs(String))
	}
}*/