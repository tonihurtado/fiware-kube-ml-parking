FROM tonihurtado/pyspark-notebook
USER root
ADD https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz /opt/spark-3.1.2
ADD https://repo1.maven.org/maven2/org/mongodb/spark/mongo-spark-connector_2.12/3.0.1/mongo-spark-connector_2.12-3.0.1.jar /usr/local/spark/jars
RUN ln -s /opt/spark-3.1.2 /opt/spark
RUN export SPARK_HOME=/opt/spark
RUN export PATH=$SPARK_HOME:$PATH
RUN pip install pymongo pyspark findspark
USER jovyan
