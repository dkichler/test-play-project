package application

import play.api._
import play.api.inject.guice._

object GuiceSpecHelper {

  /**
   * Provides a fake application wired with a test Guice environment.  Allows mock config and overriding of bindings.
   * Disables the ServiceModule
   *
   * @param config Map of test config key pairs
   *
   * @return A faked out GuiceApplicationBuilder
   */
  def fakeAppBuilder(config: Map[String, Any]): GuiceApplicationBuilder = new GuiceApplicationBuilder()
    .in(Mode.Test)
    .disable[ServiceModule]
    .configure(config)
}
