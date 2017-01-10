package shy.xhelper.ebean

import com.avaje.ebean.Model
import com.avaje.ebean.annotation.CreatedTimestamp
import com.avaje.ebean.annotation.SoftDelete
import com.avaje.ebean.annotation.UpdatedTimestamp
import com.fasterxml.jackson.annotation.JsonIgnore
import java.time.LocalDateTime
import javax.persistence.Id
import javax.persistence.MappedSuperclass
import javax.persistence.Version
import shy.xhelper.data.gen.GenAccessors

@GenAccessors
@MappedSuperclass
class BaseModel extends Model implements IEntity {
	@Id
	Long id
	
	//@JsonIgnore(serialize=true)
	@Version
	Long version
	
	@JsonIgnore
	@SoftDelete
	Boolean deleted = false
	
	@JsonIgnore
	@CreatedTimestamp
	LocalDateTime createdAt
	
	@JsonIgnore
	@UpdatedTimestamp
	LocalDateTime updatedAt
}