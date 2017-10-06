# Introduction

A template for a [Play Framework](https://playframework.com/)/[Scala](http://www.scala-lang.org/) microservice without any user interface.
Requires JDK 8+.

See the [Microservice provisioning and deployment guide](https://kashoo.atlassian.net/wiki/x/DwCvAw) for additional info on getting the
service deployed to the world.

# Setup

1. Set `name` property in build.sbt
2. Update `scalaVersion` property in build.sbt to latest Scala version
3. Update `sbt.version` property in project/build.properties to latest [sbt](http://www.scala-sbt.org/) version
4. Update `com.typesafe.play:sbt-plugin` dependency in project/plugins.sbt to latest version of Play Framework
5. Set `ROLE_NAME` field in etc/deploy.sh to the name of the deployment role that will be used to identify cloud server nodes in the
[provision-node.sh](https://github.com/Kashoo/ops-tools/blob/master/cloud/provision-node.sh) script. By convention, this should be defined
in snake_case; e.g. `play_microservice`.
6. Set `APP_ID` field in etc/deploy.sh to match the app's name
7. Update the paths for the default routes in conf/routes to match the app's name

# Notes

The scoverage-sbt plugin is included by default for test coverage reports.  To generate a coverage report: `./activator coverage test`

Includes a custom sbt build task to generate various metadata about the build (e.g. date/time, commit, user).  This is useful when the
service is deployed to staging and production because it removes ambiguity about which version is live.

* To execute the build task: `./activator build-info`.
* To view the build info on a local running app (substitute app name in the URL path where appropriate):
http://localhost:9000/play-microservice/resources/build-info.json

The application.ServiceModule class is responsible for providing custom instances for dependency injection into controllers et al.  For most
dependencies it will not be necessary to define a custom provider, but the class exists just in case. Read more on Play Framework's
dependency injection support in [ScalaDependencyInjection](https://www.playframework.com/documentation/2.4.x/ScalaDependencyInjection).

The application.GuiceSpecHelper class in the test directory can be used to fake out an Application with custom dependency injection
behaviour in test cases.

The conf/application.conf config file specifies `include "dev.conf"` which allows a developer to create a conf/dev.conf to override the
default values from conf/application.conf with their own environment-specific values.  And, since `dev.conf` is listed in .gitignore, the
file should never be accidentally committed to the repo.

The project also references Kashoo Artifactory server for internal dependencies.  Artifactory requires authentication that must be
defined in `$HOME/.ivy2/.credentials`:

    realm=Artifactory Realm
    host=artifactory.kashoo.net
    user=developers
    password=<stored in Passpack entry "Artifactory">
