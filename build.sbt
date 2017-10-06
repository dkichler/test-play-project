name := """play-microservice"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.8"

resolvers ++= Seq(
  "Kashoo Artifactory" at "https://artifactory.kashoo.net/artifactory/repo",
  "Typesafe repository" at "https://repo.typesafe.com/typesafe/releases/",
  "scalaz-bintray" at "http://dl.bintray.com/scalaz/releases",
  Classpaths.sbtPluginReleases
)

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  "com.github.nscala-time" %% "nscala-time" % "2.8.0" % Compile,
  specs2 % Test,
  "org.mockito" % "mockito-core" % "1.9.5" % Test,
  "de.leanovate.play-mockws" %% "play-mockws" % "2.4.2" % Test
)

credentials += Credentials(Path.userHome / ".ivy2" / ".credentials")

routesGenerator := InjectedRoutesGenerator

ScoverageSbtPlugin.ScoverageKeys.coverageExcludedPackages := """<empty>;Reverse.*;router\..+;application\.ServiceModule"""

// excludes ScalaDoc from build and distribution
sources in (Compile,doc) := Seq.empty
publishArtifact in (Compile, packageDoc) := false

// target for creating build info directory - will be served from 'public' in the base dir
val buildInfoTarget = TaskKey[File]("build-info-target")

buildInfoTarget <<= baseDirectory(_ / "public") map { buildInfoDir: File =>
  IO.createDirectory(buildInfoDir)
  buildInfoDir
}

// ensure public is cleaned up
cleanFiles <+= baseDirectory(_ / "public")

// task for generating build-info.json
val buildInfoTask = TaskKey[File]("build-info")

buildInfoTask := {
  val buildInfoFile: File = buildInfoTarget.value / "build-info.json"
  "etc/build-info.sh" #> buildInfoFile ! streams.value.log
  buildInfoFile
}

// hook build info generation into both run and tarball tasks
run in Compile <<= (run in Compile).dependsOn(buildInfoTask)
mappings in Universal <<= (mappings in Universal).dependsOn(buildInfoTask)
mappings in Universal ++= Seq((buildInfoTask.value.getAbsoluteFile, "public/build-info.json"))

// for services managed by Chef, local configuration and distribution artifacts should not be bundled
// this filters out conf & bin directories
mappings in Universal := {
  (mappings in Universal).value filter {
    case (file, name) =>  ! (name.startsWith("conf/") || name.startsWith("bin/"))
  }
}
