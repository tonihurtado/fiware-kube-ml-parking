#!/bin/bash
k apply -f pv.yaml
k apply -f jupyterlab-pvc.yaml
k apply -f jupyterlab-deployment.yaml
k apply -f mongodb-pvc.yaml
k apply -f mongodb-deployment.yaml
k apply -f mongodb-service.yaml
k apply -f jupyterlab-service.yaml
