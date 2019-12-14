#!/bin/bash
# Generate kube-controller-manager kubeconfig

kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="../ca/ca.pem" \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
    --client-certificate="../ca/kube-controller-manager.pem" \
    --client-key="../ca/kube-controller-manager-key.pem" \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig