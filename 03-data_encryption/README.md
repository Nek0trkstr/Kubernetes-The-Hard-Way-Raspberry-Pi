## Encrypt secrets at rest
Kubernetes provides tools to encrypt secrets while they are stored on a disk.
Here we will generate a k8s EncryptionConfig fiile.
Data will be encypted using AES-CBC with PKCS#7 padding algorithm.
More info can be found at [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

Encryption config file should be copied to admin nodes.