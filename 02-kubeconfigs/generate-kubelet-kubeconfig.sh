#!/bin/bash
# Generaiting kubelet's kubeconfig for every instance in worker-instances.txt file

KUBERNETES_ADDRESS=192.168.1.200

while read -r INSTANCE; do
    echo "Generating kubelet kubeconfig for $INSTANCE"
    kubectl config set-cluster kubernetes-the-hard-way \
        --certificate-authority="../01-ca/ca.pem" \
        --embed-certs=true \
        --server=https://${KUBERNETES_ADDRESS}:6443 \
        --kubeconfig=${INSTANCE}.kubeconfig

    kubectl config set-credentials system:node:${INSTANCE} \
        --client-certificate="../01-ca/${INSTANCE}.pem" \
        --client-key="../01-ca/${INSTANCE}-key.pem" \
        --embed-certs=true \
        --kubeconfig=${INSTANCE}.kubeconfig

    kubectl config set-context default \
        --cluster=kubernetes-the-hard-way \
        --user=system:node:${INSTANCE} \
        --kubeconfig=${INSTANCE}.kubeconfig

  kubectl config use-context default --kubeconfig=${INSTANCE}.kubeconfig
done < "worker_instances.txt"