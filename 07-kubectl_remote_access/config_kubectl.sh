#!/bin/bash
# Config kubectl for remote access

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority='../01-ca/ca.pem' \
  --embed-certs=true \
  --server=https://k8s-lb-1:6443

kubectl config set-credentials admin \
  --client-certificate='../01-ca/admin.pem' \
  --client-key='../01-ca/admin-key.pem'

kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context kubernetes-the-hard-way