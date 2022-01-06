#!/bin/bash
set -xe

sbt clean
sbt assembly
rm -rf spark-3.1.2/jars/tfm-assembly.jar
cp target/scala-2.12/tfm-assembly-1.1.jar spark-3.1.2/jars/tfm-assembly.jar

./spark-3.1.2/bin/docker-image-tool.sh -r tonihurtado -t $1 -f spark-3.1.2/kubernetes/dockerfiles/spark/Dockerfile build
./spark-3.1.2/bin/docker-image-tool.sh -r tonihurtado -t $1 -f spark-3.1.2/kubernetes/dockerfiles/spark/Dockerfile push

CLUSTER_IP=$(minikube ip)
./spark-3.1.2/bin/spark-submit \
    --master k8s://https://$CLUSTER_IP:8443 \
    --deploy-mode cluster \
    --name spark-train \
    --class org.fiware.cosmos.orion.spark.connector.prediction.Train \
    --packages "org.mongodb.spark:mongo-spark-connector_2.12:3.0.1" \
    --conf "spark.executor.instances=1" \
    --conf "spark.executor.cores=4" \
    --conf "spark.executor.memory=12G"   \
    --conf "spark.kubernetes.container.image=tonihurtado/spark:$1" \
    --conf "spark.kubernetes.namespace=tfm" \
    --conf "spark.kubernetes.authenticate.driver.serviceAccountName=spark" \
    --conf "spark.driver.extraJavaOptions=-Divy.cache.dir=/tmp -Divy.home=/tmp" \
    --conf "spark.driver.file.upload.path=/opt/spark/work-dir/" \
    --conf "spark.local.dir=/opt/spark/work-dir/" \
    --conf "spark.kubernetes.driver.label.job=train" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.options.claimName=spark-pvc" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.mount.path=/opt/spark/work-dir/models/" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.mount.readOnly=false" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.options.claimName=spark-pvc" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.mount.path=/opt/spark/work-dir/models/" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.mount.readOnly=false" \
    local:///opt/spark/jars/tfm-assembly.jar
