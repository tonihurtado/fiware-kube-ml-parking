#!/bin/bash
kubectl create namespace tfm
kubectl apply -f kubernetes/mongodb-sc.yaml
kubectl apply -f kubernetes/mongodb-statefulSet.yaml
echo "🥝 Starting database... [1m]"
sleep 60
echo "📚 Configuring replicaset... [30s]"
sh statefulset/mongodb-rsconfig.sh mongodb-0
kubectl apply -f kubernetes/mongodb-hservice.yaml
echo "📖 Starting mongodb UI... [1s]"
kubectl apply -f kubernetes/mongodb-express.yaml
sleep 10
echo "🌆 Starting context broker and draco (Fiware)... [5s]"
kubectl apply -f kubernetes/orion-service.yaml
kubectl apply -f kubernetes/orion-deployment.yaml
git clone https://github.com/ging/fiware-draco.git
kubectl apply -f kubernetes/draco-service.yaml
kubectl apply -f kubernetes/draco-deployment.yaml
sleep 10
echo "🔖 Starting Spark service account,volumes and services... [30s]"
kubectl create -n tfm serviceaccount spark
kubectl create -n tfm clusterrolebinding spark-role --clusterrole=edit --serviceaccount=tfm:spark --namespace=tfm
kubectl apply -f kubernetes/spark-pv.yaml
kubectl apply -f kubernetes/spark-pvc.yaml
kubectl apply -f kubernetes/spark-hservice.yaml
sleep 30
echo "💻 Starting Web UI..."
kubectl apply -f kubernetes/prediction-web-deployment.yaml
sleep 2
echo "🛀 Running sink Job..."
kubectl apply -f kubernetes/Jobs/sink-job.yaml
sleep 5
echo "🍎 Creating ORION entities and subscriptions..."
pushd prediction-web/entities
sh curlEntities.sh
sleep 10
popd
echo "🍏 Submitting spark prediction Job..."
cd spark-job
mkdir -p spark-3.1.2 && curl -L https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz | tar -zx -C spark-3.1.2/ --strip 1
sh spark-submit-predict.sh
sleep 20
echo "Done ✅"
echo "🔘 Accessible services:"
minikube service list