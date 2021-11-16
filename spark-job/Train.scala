package org.fiware.cosmos.orion.spark.connector.prediction

import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.evaluation.RegressionEvaluator
import org.apache.spark.ml.feature.{VectorAssembler,StringIndexer,OneHotEncoder}
import org.apache.spark.ml.regression._
import org.apache.spark.sql.{DataFrame, SparkSession}
import org.apache.spark.sql.types.{IntegerType, StringType, StructField, StructType}
import org.apache.spark.sql.functions._
import com.mongodb.spark._
import com.mongodb.spark.config.ReadConfig
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object Train {

  val mongo_uri = "mongodb://mongodb-0.mongodb-svc.tfm.svc.cluster.local:27017,mongodb-1.mongodb-svc.tfm.svc.cluster.local:27017,mongodb-2.mongodb-svc.tfm.svc.cluster.local:27017/tfm.parking?replicaSet=MainRepSet"//"mongodb://mongodb-svc:27017/tfm.parking"
  val db_name = "tfm.parking"

  def main(args: Array[String]): Unit = {
    val now = LocalDateTime.now.format(DateTimeFormatter.ofPattern("YYYYMMdd_HHmm"))
    val desc = "lr-1"
    val model_name = s"$desc-$now"
    println(s"Model name will be: $model_name")
    
    val (lrModel, pipeline) = train()
    lrModel.write.save(s"./models/model-$model_name")
    lrModel.write.overwrite().save(s"./models/model")
    pipeline.write.save(s"./models/pipeline-$model_name")
    pipeline.write.overwrite().save(s"./models/pipeline")
  }
  
  def train() = {
    val spark = SparkSession
      .builder
      .appName("tfm")
      .config("spark.mongodb.input.uri",mongo_uri)
      .getOrCreate()
      
    val sc = spark.sparkContext
    import spark.implicits._
    val data = sc.loadFromMongoDB()
    data.toDF().show(false)
    val df_orig = data.toDF().select($"name.value".alias("name"),$"availableSpotNumber.value".cast("int").alias("availableSpotNumber"),$"availableSpotNumber.metadata.timestamp.value".alias("timestamp"))
    val df = df_orig.where("availableSpotNumber != -1")
        .withColumn("timestamp",to_timestamp($"timestamp","yyyy-MM-dd'T'HHmm"))
        .withColumn("weekday",dayofweek($"timestamp"))
        .withColumn("day",dayofmonth($"timestamp"))
        .withColumn("month",month($"timestamp"))
        .withColumn("hour",hour($"timestamp"))
        .withColumn("minute",minute($"timestamp"))
        .withColumn("hour_interval",round($"minute"/30).cast("Int")*30)
        //.withColumn("time", concat_ws(":",$"hour".cast("String"),$"hour_interval".cast("String")))
    df.show(false)

    val it = Array("name")
    
    val stringIndexers = it.map (
        c => new StringIndexer().setInputCol(c).setOutputCol(s"${c}-index")
    )
    val oneHotEncoders = it.map (
        c => new OneHotEncoder().setInputCol(s"${c}-index").setOutputCol(s"${c}-ohe")
    )

    //val vectorAssembler = new VectorAssembler().setInputCols(Array("name-ohe","weekday-ohe","time-ohe")).setOutputCol("features")
    val vectorAssembler = new VectorAssembler().setInputCols(Array("name-index","weekday","hour")).setOutputCol("features")

    val rf = new RandomForestRegressor()
      .setLabelCol("availableSpotNumber")
      .setFeaturesCol("features")

    val lr = new LinearRegression()
      .setLabelCol("availableSpotNumber")
      .setFeaturesCol("features")
      .setMaxIter(100)


    val pipeline = new Pipeline().setStages(stringIndexers ++ Array(vectorAssembler,lr))
    val predPipeline = new Pipeline().setStages(stringIndexers ++ Array(vectorAssembler))
    val Array(trainingData,testData) = df.randomSplit(Array(0.7,0.3))
    val model = pipeline.fit(trainingData)
    val predModel = predPipeline.fit(trainingData)
    val predictions = model.transform(testData)
    predictions.select("prediction", "availableSpotNumber", "hour", "weekday", "name").show(30)
    
    // Evaluating the Result
    val evaluator = new RegressionEvaluator()
      .setLabelCol("availableSpotNumber")
      .setPredictionCol("prediction")
      .setMetricName("rmse")
    val rmse = evaluator.evaluate(predictions)

    println(s"Root Mean Squared Error (RMSE) on test data = $rmse")

    val lrModel = model.stages.last.asInstanceOf[LinearRegressionModel]
    (lrModel,predModel)
  }
}