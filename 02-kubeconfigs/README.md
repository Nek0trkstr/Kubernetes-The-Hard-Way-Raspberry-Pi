# Generate a kubeconfig files

Generate kubeconfig files using kubectl.
Kubeconfig files describes which cluster to use and how to authorize within this cluster using previously generated certificates

## Usage 
 - Set worker nodes names in worker_instances.txt - every instance in new line
 - Set Kubernetes LB adress in each script
 - Run scripts

## About scripts
Set cluster name and address as well as certificate authority
```
kubectl config set-cluster
```

Set an user entry in kubeconfig
```
kubectl config set-credentials
```

Set an context in kubeconfig (More about context can be found in [Docs](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/))
```
kubectl config set-context 
```

## Copy kubeconfigs to nodes
Worker nodes needs <worker-instance>.kubeconfig and kube-proxy.kubeconfig
Admin nodes needs admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig