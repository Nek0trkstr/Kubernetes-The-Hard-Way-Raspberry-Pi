# Config Master Nodes
etcd is a distributed key-value store, k8s uses to manage cluster.
Since etcd is written in golang we can compile it to ARM.

## Compile etcd to ARM
Clone etcd code to your workstation (master branch may be unstable or broken so it makes sense to get source code from one of the releases)
```
git clone git@github.com:coreos/etcd.git
cd etcd
```

Now you are ready to compile project. ARMv6 is compatible with newer architectures.
```
export GOOS="linux"
export GOARCH="arm"
export CGO_ENABLED=0
export GOARM=6
go build -o "bin/etcd" .
go build -o "bin/etcdctl" ./etcdctl
```

## Configure etcd
Move binaries and certs to their desired location.
```
sudo mv etcd* /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
```

Lets predefine variables that will help etcd initialize cluster, since its a distributed solution.
'INITIAL_CLUSTER' parameter is an comma-separated value that should be of form next form: 
$HOSTNAME1=https://$INTERNAL_IP1:2380,$HOSTNAME2=https://$INTERNAL_IP2:2380 etc...
My setup have only 1 master node so 'INITIAL_CLUSTER' contains only one machine. 
```
ETCD_NAME=`hostname`
INTERNAL_IP=$(ifconfig eth0 | grep inet | sed -n '1p' | awk '{print $2}')
INITIAL_CLUSTER="$HOSTNAME=https://$INTERNAL_IP:2380"
```

### Install as a service
```
cat << EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${INITIAL_CLUSTER} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
Environment="ETCD_UNSUPPORTED_ARCH=arm"

[Install]
WantedBy=multi-user.target
EOF
```

### Start etcd
```
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd
```

### Verify 
Look for errors in journalctl
```
journalctl -u etcd.service -l --no-pager|less +G
```

Check that all instances appeared
```
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```

