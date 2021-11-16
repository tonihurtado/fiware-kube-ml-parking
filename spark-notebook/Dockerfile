FROM jupyter/all-spark-notebook
USER root
ADD https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz /opt/spark-3.1.2
ADD https://repo1.maven.org/maven2/org/mongodb/spark/mongo-spark-connector_2.12/3.0.1/mongo-spark-connector_2.12-3.0.1.jar /usr/local/spark/jars
ADD https://github.com/ging/fiware-cosmos-orion-spark-connector/releases/download/FIWARE_8.1/orion.spark.connector-1.2.2.1.jar /usr/local/spark/jars
RUN ln -sf /opt/spark-3.1.2 /opt/spark
RUN export SPARK_HOME=/opt/spark
RUN export PATH=$SPARK_HOME:$PATH
USER jovyan
