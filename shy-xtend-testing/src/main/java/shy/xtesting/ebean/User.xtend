package shy.xtesting.ebean

import shy.xhelper.ebean.XEntity
import java.time.LocalDate
import javax.persistence.CascadeType
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull

@XEntity
class User {
	@NotNull String name
	@NotNull String email
	@NotNull LocalDate birthdate
	
	@ManyToOne(cascade=CascadeType.ALL)
	Address address
}