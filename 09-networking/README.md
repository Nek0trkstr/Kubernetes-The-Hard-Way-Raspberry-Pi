# Container Network Interface (CNI)
CNI is a network plugin or service-mesh that k8s uses to reliably deliver requests between services. [Read More](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
Here we will install Weave Net CNI

## Prerequsities
Run this on every worker node
```
sudo sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
sudo rpi-update # Needed for weave net
sudo apt-get install socat # Needed for port-forwarding
```

## Weave Net Install
This will install a DaemonSet that will control our networking, run from you machine:
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.200.0.0/16"
```

## Now test
### Deploy 2 nginx services
Run from your workstation
```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      run: nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

### Create a service for nginx pods
```
kubectl expose deployment/nginx
```

### Create a busybox (client) pod
```
run busybox --image=busybox --command -- sleep 3600
```

### Test connection from client to pods
```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl get ep nginx
kubectl exec -ti $POD_NAME -- wget -O testfilename <EP_ADDRESS>
kubectl get service/nginx
kubectl exec -ti $POD_NAME -- wget -O testfilename <SERVICE_ADDRESS>
```

## Cleanup
```
kubectl delete deployment nginx
kubectl delete deployment busybox
```


