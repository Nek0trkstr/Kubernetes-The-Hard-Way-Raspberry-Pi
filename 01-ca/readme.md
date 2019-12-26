## Generating an CA and certificates for k8s cluster.

First, install **cfssl**:
```
brew install cfssl
```

Write an **ca-config.json**:
```
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
```

Create a CSR for your new CA **ca-csr.json**
```
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "<Country>",
      "L": "<City/Locality>",
      "O": "<Organization Name>",
      "OU": "<Organization Unit Name>",
      "ST": "<State>"
    }
  ]
}
```

Now you are ready to initialize a CA.
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

Generate an Admin Client Certificate:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
```

Generate an Kubelet Client Certificate:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKER_IP},${WORKER_HOST} \
  -profile=kubernetes \
  ${WORKER_HOST}-csr.json | cfssljson -bare ${WORKER_HOST}
```

Generate Controller Manager Client Certificate:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
```

Generate Kube Proxy Client certificate:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
```

Generate Kube Scheduler Client Certificate:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
```

Generate Kubernetes API Server Certificate:
```
CERT_HOSTNAME=10.32.0.1,<controller node 1 Private IP>,<controller node 1 hostname>,<controller node 2 Private IP>,<controller node 2 hostname>,<API load balancer Private IP>,<API load balancer hostname>,127.0.0.1,localhost,kubernetes.default

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${CERT_HOSTNAME} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```

Generate Service Account Key Pair:
```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
```

Copy certificates to worker Nodes:
```
scp ca.pem <worker1 hostname>-key.pem <worker1 hostname>.pem user@<worker1 IP>:~/
scp ca.pem <worker2 hostname>-key.pem <worker2 hostname>.pem user@<worker2  IP>:~/
```

Copy certificates to master nodes
```
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem user@<master1 IP>:~/
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem user@<master2 IP>:~/
```