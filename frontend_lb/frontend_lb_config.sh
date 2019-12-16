#/bin/bash
# Config frontend load balancer to access kube api server

sudo apt-get update
sudo apt-get install -y nginx
sudo mkdir -p /etc/nginx/tcpconf.d
echo "include /etc/nginx/tcpconf.d/*;" | sudo tee -a /etc/nginx/nginx.conf
CONTROLLER0_IP=192.168.1.150
cat << EOF | sudo tee /etc/nginx/tcpconf.d/kubernetes.conf
stream {
    upstream kubernetes {
        server $CONTROLLER0_IP:6443;
    }

    server {
        listen 6443;
        listen 443;
        proxy_pass kubernetes;
    }
}
EOF
sudo nginx -s reload