package application

import com.google.inject.Singleton
import play.api.mvc._

/**
 * Responsible for providing health check endpoints
 */
@Singleton
class HealthcheckController extends Controller {

  /**
   * Simple endpoint to indicate the application is running
   */
  def available = Action { Ok("success") }
}
