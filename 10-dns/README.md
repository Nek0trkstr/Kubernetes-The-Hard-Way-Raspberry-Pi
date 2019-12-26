# DNS
It's actually pretty easy to config DNS in k8s (except monstrous yaml file) so lets dive into it.
[Read More](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
This lab is should run on your workstation.

## Install DNS
```
kubectl create -f kube-dns.yaml
```

## Test DNS resolution
```
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

## Cleanup
```
kubectl delete deployment busybox
```

