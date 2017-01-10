package shy.testing.ebean

import com.avaje.ebean.Ebean
import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.config.ServerConfig
import java.time.LocalDate
import java.time.Month
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import shy.xtesting.ebean.Address
import shy.xtesting.ebean.Country
import shy.xtesting.ebean.User

class TestEbeanPersistence {
	@BeforeClass
	static def void setup() {
		val config = new ServerConfig => [
			name = 'db'
			defaultServer = true
			loadTestProperties
		]
		
		EbeanServerFactory.create(config)
	}
	
	@Test
	def void testCountry() {
		Ebean.execute[
			val inCountry = new Country => [
				code = '+351'
				name = 'Portugal'
				save
			]
			
			val inAddress = new Address => [
				city = 'Aveiro'
				country = inCountry
				//save - no need because of User.address -> CascadeType.ALL
			]
			
			new User => [
				name = 'Alex Bruto'
				email = 'alex@gmail.com'
				birthdate = LocalDate.of(2017, Month.JANUARY, 1)
				
				address = inAddress
				save
			]
		]
		
		Country.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"code":"+351","name":"Portugal"}', toJson)
		]
		
		Address.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"city":"Aveiro","country":{"id":1,"type":"ref","to":"shy.xtesting.ebean.Country"}}', toJson)
		]
		
		User.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"name":"Alex Bruto","email":"alex@gmail.com","birthdate":"2017-01-01","address":{"id":1,"type":"ref","to":"shy.xtesting.ebean.Address"}}', toJson)
		]
	}
}