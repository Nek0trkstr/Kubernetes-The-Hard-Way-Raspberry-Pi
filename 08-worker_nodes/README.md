# Worker Nodes
Worker nodes are machines that will run actuall worloads for you.
Here we will install all components this node need to be part of k8s cluster.

## Binaries
Download binaries and move them to desired location
```
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.0.0-beta.0/crictl-v1.0.0-beta.0-linux-arm.tar.gz \
  https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-arm-v0.6.0.tgz \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/arm/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/arm/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/arm/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet  /usr/local/bin/
sudo tar -xvf crictl-v1.0.0-beta.0-linux-arm.tar.gz  -C /usr/local/bin/
sudo tar -xvf cni-plugins
```

## Container runtime
We need a container runtime to run containers in our nodes. Here we will use docker as a container runtime. [Read more](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
[Deep Dive](https://www.ianlewis.org/en/container-runtimes-part-1-introduction-container-r)
```
curl -fsSL get.docker.com | sh
sudo usermod -aG docker pi
echo "deb https://download.docker.com/linux/raspbian/ stretch stable" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo systemctl start 
```
Restart machine if you want to run docker without sudo

## Kubelet
Kubelet is component that managing a worker node. [Read more](https://kubernetes.io/docs/concepts/overview/components/#node-components)
Here we will provide a container runtime
```
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

cat << EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS: 
  - "10.32.0.10"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

cat << EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=docker \\
  --docker=unix:///var/run/docker.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2 \\
  --hostname-override=${HOSTNAME} \\
  --allow-privileged=true
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## Kube-proxy
Kube-proxy maintains networking rules on a worker node. [Read More](https://kubernetes.io/docs/concepts/overview/components/#node-components)
[How doest the kubernetes networking work (1/3)](https://medium.com/@tao_66792/how-does-the-kubernetes-networking-work-part-1-5e2da2696701)
```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
cat << EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

cat << EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## Enable services
```
sudo systemctl daemon-reload
sudo systemctl enable docker kubelet kube-proxy
sudo systemctl start docker kubelet kube-proxy
```