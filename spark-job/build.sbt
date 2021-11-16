name := "tfm"
version := "1.1"
organization := "upm"
scalaVersion := "2.12.13"
val sparkVersion = "3.0.1"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
  "org.mongodb.spark" %% "mongo-spark-connector" % "3.0.1",
)

resolvers += "snapshots" at "https://oss.sonatype.org/content/repositories/snapshots"

resolvers += "releases"  at "https://oss.sonatype.org/content/repositories/releases"


assemblyMergeStrategy in assembly := {
 case PathList("META-INF", xs @ _*) => MergeStrategy.discard
 case x => MergeStrategy.first
}