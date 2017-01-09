package shy.xtesting.ebean

import shy.xhelper.ebean.XEntity
import javax.validation.constraints.NotNull

@XEntity
class Country {
	@NotNull String code
	@NotNull String name
}