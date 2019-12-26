# Smoke Test
We will test most easily broken k8s features

## Data encryption
Validate that data is encrypted at rest.
Create a secret.
```
kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"
```

SSH to one of the master nodes and run:
```
sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C
```

Should get encrypted data like this:
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 79 e9 be ba c5 74 97  |:v1:key1:y....t.|
00000050  3a 1c 68 98 f5 e8 e8 c5  d6 69 df 4e c0 75 33 17  |:.h......i.N.u3.|
00000060  7f 57 05 92 d2 90 8b 84  80 5c c5 00 be 85 17 9c  |.W.......\......|
00000070  cc 09 8d eb 84 75 23 78  b2 b1 52 db 5a 20 22 81  |.....u#x..R.Z ".|
00000080  96 5f b2 f8 0f 08 81 1b  c9 b4 07 dc c6 34 15 5e  |._...........4.^|
00000090  4a 27 1f e0 32 f8 20 f3  70 14 2d a5 96 f5 8a 05  |J'..2. .p.-.....|
000000a0  50 e7 90 db f3 18 e4 f3  8c 28 28 48 74 f4 f9 4e  |P........((Ht..N|
000000b0  91 b8 37 06 08 1d 20 6f  05 90 80 08 49 ad 44 01  |..7... o....I.D.|
000000c0  e1 b4 be 4e 86 c8 1b 9a  19 8c 98 3a 36 8a a6 fa  |...N.......:6...|
000000d0  5a 50 5e 68 8a a2 26 4b  2b 1c da ed 2f e5 5f 9b  |ZP^h..&K+.../._.|
000000e0  87 7b 91 42 a1 4c 5c 52  56 0a                    |.{.B.L\RV.|
000000ea

**k8s:enc:aescbc** - check that it's appear on right side of the window

## Deployments
Check if deployments are working properly.
Create a pod.
```
kubectl run nginx --image=nginx
```

Validate that nginx pod started.
```
kubectl get pods -l run=nginx
```

Look for ready state of pods
NAME                     READY     STATUS    RESTARTS   AGE
nginx-65899c769f-b8r2j   1/1       Running   0          9s

## Port-Forwarding
Use same pod as in deployments smoke-test
```
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8081:80
curl http://localhost:8081
```

## Logs
Logs are working as expected.
```
kubectl logs $POD_NAME
```

## Exec
Check if you are able to execute command inside a pod
```
kubectl exec -ti $POD_NAME -- nginx -
```

## Services
Check that services are working properly and are exposing pods
```
kubectl expose deployment nginx --port 80 --type NodePort
NODE_PORT=$(kubectl get service -l run=nginx -o jsonpath="{.items[0].spec.ports[0].nodePort}")
curl http://k8s-node-1:$NODE_PORT
```

## Cleanup
Delete resources created for smoke tests
```
kubectl delete secret kubernetes-the-hard-way
kubectl delete svc nginx
kubectl delete deployment nginx
```