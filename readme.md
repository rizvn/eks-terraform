Set Default AWS Profile to ue
```bash
export AWS_PROFILE=test
```

Update 01-variable.tf

Deploy 
```bash
terraform init
terraform plan
```


Update kubeconfg for the new cluster
```bash
aws eks update-kubeconfig --region us-east-1 --name cluster-01
kubectl get nodes
```

Test users
```bash
aws configure --profile user1
# set access id and secret key
kubectl get nodes
```


References
source: https://github.dev/antonputra/tutorials/blob/main/lessons/125/terraform/1-vpc.tf
source: https://github.com/mstiri/eks-cluster/blob/main/cluster.tf#L23

