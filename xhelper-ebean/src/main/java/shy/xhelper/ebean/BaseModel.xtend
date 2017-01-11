package shy.xhelper.ebean

import com.avaje.ebean.Model
import com.avaje.ebean.annotation.CreatedTimestamp
import com.avaje.ebean.annotation.SoftDelete
import com.avaje.ebean.annotation.UpdatedTimestamp
import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonProperty
import java.time.LocalDateTime
import javax.persistence.Id
import javax.persistence.MappedSuperclass
import javax.persistence.Version
import org.eclipse.xtend.lib.annotations.Accessors

@MappedSuperclass
class BaseModel extends Model {
	@Id
	@Accessors Long id
	
	@Version
	@JsonProperty(access=READ_ONLY)
	@Accessors(PUBLIC_GETTER) Long version
	
	@JsonIgnore
	@SoftDelete
	@Accessors(PUBLIC_GETTER) Boolean deleted = false
	
	@JsonIgnore
	@CreatedTimestamp
	@Accessors(PUBLIC_GETTER) LocalDateTime createdAt
	
	@JsonIgnore
	@UpdatedTimestamp
	@Accessors(PUBLIC_GETTER) LocalDateTime updatedAt
}