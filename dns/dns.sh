#!/bin/bash

# deploy kubedns
kubectl create -f kube-dns.yaml
kubectl get pods -l k8s-app=kube-dns -n kube-system

# deploy busybox
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600


# test dns resolution
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes

# delete busybox
kubectl delete deployment busybox