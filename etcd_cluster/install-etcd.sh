#!/bin/bash
# Install etcd on raspberry pi admin node

# Compile etcd for ARM architecture
git clone git@github.com:coreos/etcd.git
cd etcd

export GOOS="linux"
export GOARCH="arm"
export CGO_ENABLED=0
export GOARM=6
go build -o "bin/etcd" .
go build -o "bin/etcdctl" ./etcdctl

# Get etcd binaries and provide certificates
sudo mv etcd* /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

ETCD_NAME=`hostname`
INTERNAL_IP=$(ifconfig eth0 | grep inet | sed -n '1p' | awk '{print $2}')
INITIAL_CLUSTER="$HOSTNAME=https://$INTERNAL_IP:2380"

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

# Start etcd service
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd

# Check logs
journalctl -u etcd.service -l --no-pager|less +G

# Verify that all etcd instances apeared
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
