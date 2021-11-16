
#!/bin/bash
./spark-3.1.2/bin/spark-submit \
    --master k8s://https://192.168.49.2:8443 \
    --deploy-mode cluster \
    --name spark-prediction \
    --class org.fiware.cosmos.orion.spark.connector.prediction.Prediction \
    --packages "org.mongodb.spark:mongo-spark-connector_2.12:3.0.1" \
    --conf "spark.executor.instances=1" \
    --conf "spark.kubernetes.container.image=tonihurtado/spark:$1" \
    --conf "spark.kubernetes.namespace=tfm" \
    --conf "spark.kubernetes.authenticate.driver.serviceAccountName=spark" \
    --conf "spark.driver.extraJavaOptions=-Divy.cache.dir=/tmp -Divy.home=/tmp" \
    --conf "spark.driver.file.upload.path=/opt/spark/work-dir/" \
    --conf "spark.local.dir=/opt/spark/work-dir/" \
    --conf "spark.kubernetes.driver.label.job=prediction" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.options.claimName=spark-pvc" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.mount.path=/opt/spark/work-dir/models/" \
    --conf "spark.kubernetes.driver.volumes.persistentVolumeClaim.data.mount.readOnly=false" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.options.claimName=spark-pvc" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.mount.path=/opt/spark/work-dir/models/" \
    --conf "spark.kubernetes.executor.volumes.persistentVolumeClaim.data.mount.readOnly=false" \
    local:///opt/spark/jars/tfm-assembly.jar