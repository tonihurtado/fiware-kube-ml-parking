package org.fiware.cosmos.orion.spark.connector.prediction

import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.ml.{Pipeline, PipelineModel}
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.{VectorAssembler,StringIndexer,OneHotEncoder}
import org.fiware.cosmos.orion.spark.connector.{ContentType, HTTPMethod, OrionReceiver, OrionSink, OrionSinkObject}
import org.apache.spark.ml.regression._
import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.sql.types.{IntegerType, StringType, StructField, StructType}
import org.apache.spark.sql.functions._
import com.mongodb.spark._
import com.mongodb.spark.config.ReadConfig
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

case class PredictionResponse(socketId: String, predictionId: String, predictionValue: Int, name: String, weekday: Int, hour: Int) {
  override def toString :String = s"""{
  "socketId": { "value": "${socketId}", "type": "String"},
  "predictionId": { "value":"${predictionId}", "type": "String"},
  "predictionValue": { "value":${predictionValue}, "type": "Integer"},
  "name": { "value":"${name}", "type": "String"},
  "weekday": { "value":${weekday}, "type": "Integer"},
  "time": { "value": ${hour}, "type": "Integer"}
  }""".trim()
}
case class PredictionRequest(name: String, weekday: Int, hour: Int, socketId: String, predictionId: String)

object Prediction {
  final val URL_CB = "http://orion:1026/v2/entities/ResTicketPrediction1/attrs"
  final val CONTENT_TYPE = ContentType.JSON
  final val METHOD = HTTPMethod.PATCH
  final val BASE_PATH = "./models"

    def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder
      .appName("PredictionJob")
      .master("local[*]")
      .getOrCreate()

    spark.sparkContext.setLogLevel("WARN")

    val ssc = new StreamingContext(spark.sparkContext, Seconds(1))

    // Load model
    val model = LinearRegressionModel.load(BASE_PATH+"/model")
    val pipeline = PipelineModel.load(BASE_PATH+"/pipeline")

    // Create Orion Source. Receive notifications on port 9001
    val eventStream = ssc.receiverStream(new OrionReceiver(9001))

    // Process event stream to get updated entities
    val processedDataStream = eventStream
      .flatMap(event => event.entities)
      .map(ent => {
        println(s"ENTITY RECEIVED: $ent")
        //val year = ent.attrs("year").value.toString.toInt
        //val month = ent.attrs("month").value.toString.toInt
        //val day = ent.attrs("day").value.toString.toInt
        val name = ent.attrs("name").value.toString
        val hour = ent.attrs("time").value.toString.toInt
        val weekday = ent.attrs("weekday").value.toString.toInt
        val socketId = ent.attrs("socketId").value.toString
        val predictionId = ent.attrs("predictionId").value.toString
        PredictionRequest(name, weekday, hour, socketId, predictionId)
      })

    // Feed each entity into the prediction model
    val predictionDataStream = processedDataStream
      .transform(rdd => {
        val df = spark.createDataFrame(rdd) 
        val features  = pipeline.transform(df)
        val predictions = model
          .transform(features)
          .select("socketId","predictionId", "prediction", "name", "weekday", "hour")

        predictions.toJavaRDD
    })
      .map(pred=> PredictionResponse(
        pred.get(0).toString,
        pred.get(1).toString,
        pred.get(2).toString.toFloat.round,
        pred.get(3).toString,
        pred.get(4).toString.toInt,
        pred.get(5).toString.toInt
      )
    )

    // Convert the output to an OrionSinkObject and send to Context Broker
    val sinkDataStream = predictionDataStream
      .map(res => OrionSinkObject(res.toString, URL_CB, CONTENT_TYPE, METHOD))

    // Add Orion Sink
    OrionSink.addSink(sinkDataStream)
    sinkDataStream.print()
    predictionDataStream.print()
    ssc.start()
    ssc.awaitTermination()
  }
}