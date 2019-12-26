#!/bin/bash
# Generate kube-proxy kubeconfig

KUBERNETES_ADDRESS=192.168.1.200

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="../01-ca/ca.pem" \
    --embed-certs=true \
    --server=https://${KUBERNETES_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate="../01-ca/kube-proxy.pem" \
    --client-key="../01-ca/kube-proxy-key.pem" \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}