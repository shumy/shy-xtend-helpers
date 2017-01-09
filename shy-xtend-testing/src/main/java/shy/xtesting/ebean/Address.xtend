package shy.xtesting.ebean

import shy.xhelper.ebean.XEntity
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull

@XEntity
class Address {
	@NotNull String city
	
	@ManyToOne
	Country country
}