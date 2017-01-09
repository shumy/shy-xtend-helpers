package shy.testing.data

import org.junit.Test
import shy.xtesting.data.DataStructure
import org.junit.Assert

class TestDataStructure {
	
	@Test
	def void testBuilder() {
		val ds = DataStructure.B => [
			notAssigned1 = "n1!"
			age = 35
			correct = true
			other = 1.5F
		]
		
		Assert.assertEquals(ds.toString, '{ name: "Micael", dt: "2017-01-01", notAssigned1: "n1!", notAssigned2: "n2!", age: "35", correct: "true", other: "1.5" }')
	}
}