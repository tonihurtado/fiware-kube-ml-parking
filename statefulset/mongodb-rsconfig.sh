#!/bin/bash
echo "Configuring Replicaset"
#Arg $1 has to be the name of the master pod on the RS
kubectl exec -it -n tfm $1 -- mongo --eval "rs.initiate({ _id: "MainRepSet", version: 1, members: [ { _id: 0, host: "mongodb-0.mongodb-svc.tfm.svc.cluster.local:27017" }, { _id: 1, host: "mongodb-1.mongodb-svc.tfm.svc.cluster.local:27017" }, { _id: 2, host: "mongodb-2.mongodb-svc.tfm.svc.cluster.local:27017" } ]})"
sleep 5
kubectl exec -it -n tfm $1 -- mongo --eval "printjson(rs.status())"
sleep 5
kubectl exec -it -n tfm $1 -- mongo --eval "printjson(db.getSibilingDB("admin").createUser({ user: "toni", pwd: "admin", roles: [{role:"root",db:"admin"}]}))"