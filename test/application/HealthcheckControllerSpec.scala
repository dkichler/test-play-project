package application

import org.junit.runner.RunWith
import org.specs2.mock._
import org.specs2.mutable._
import org.specs2.runner.JUnitRunner
import play.api.test.Helpers._
import play.api.test._

@RunWith(classOf[JUnitRunner])
class HealthcheckControllerSpec extends Specification with Mockito {
  "Health check controller" should {
    "indicate success" in {
      val result = new HealthcheckController().available().apply(FakeRequest())

      status(result) must be equalTo OK
      contentAsString(result) must be equalTo "success"
    }
  }
}
