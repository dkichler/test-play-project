package application

import play.api.libs.json.Json

/*
  Represents the build info available for each release of the app, as assembled by build-info.sh
 */
case class BuildInfo(
    builtAt: String,
    builtOn: String,
    builtBy: String,
    commit: String
)

object BuildInfo {
  implicit val jsonFormat = Json.format[BuildInfo]
}
