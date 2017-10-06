package application

import java.io.{FileNotFoundException, IOException}

import com.google.inject.name.Named
import com.google.inject.{AbstractModule, Provides}
import play.api.libs.json._

import scala.io._
import scala.reflect.io._

/**
  * The service's default Guice injection module.
  */
class ServiceModule extends AbstractModule {

  @Provides @Named("kashoo-api-client-version")
  def provideKashooApiClientVersion(appDir: String = System.getProperty("user.dir"), filename: String = "build-info.json"): String = {
    getKashooApiClientVersion(s"${System.getProperty("user.dir")}/public/build-info.json")
  }

  private[application] def getKashooApiClientVersion(filename: String) = {
    val notAvailableVersion = "n/a"
    try {
      Json.parse(readFile(filename)).validate[BuildInfo] match {
        case JsError(error) => notAvailableVersion
        case JsSuccess(buildInfo, _) => buildInfo.commit
      }
    }
    catch {
      case _: IOException | _: FileNotFoundException =>
        notAvailableVersion
    }
  }

  private def readFile(filePath: Path): String = {
    val source = Source.fromFile(filePath.toAbsolute.path)
    try { source.getLines().mkString("\n") } finally { source.close() }
  }

  override def configure(): Unit = {
    // Bindings should be provided by methods marked with the @Provider annotation
  }
}
