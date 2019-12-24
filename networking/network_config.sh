#!/bin/bash
# Configure networking

sudo sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
sudo rpi-update # Needed for weave net

# from client machine
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.200.0.0/16"

# test setup by deploying 2 nginx pods and accesing them from 3rd one
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

# create service for nginx
kubectl expose deployment/nginx



# create busybox container
run busybox --image=busybox --command -- sleep 3600
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

# TODO for each nginx endpoint test connection from busybox pod
kubectl get ep nginx
kubectl exec -ti $POD_NAME -- wget -O <EP_ADDRESS>