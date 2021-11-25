CLUSTER_IP=$(minikube ip)
sh createPredictionEntities.sh $CLUSTER_IP:30329
sh subscribeReqPredictionTicket.sh $CLUSTER_IP:30329
sh subscribeResPredictionTicket.sh $CLUSTER_IP:30329
sh subscribeResDracoPredictionTicket.sh $CLUSTER_IP:30329