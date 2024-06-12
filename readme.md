The aim of this terraform project to is to create a cluster that is ready for use with all the necessary addons and features enabled.

The based scripts will create 
- VPC with 
  - 3 public subnets
  - 3 private subnets
  - NAT Gateway
  

-  EKS cluster with
  - OIDC enable for IRSA
  - With Addons
     - CoreDNS
     - VPC CNI with Network policy support
     - Kube-proxy

- ingress-only nodegroup 
- general nodegroup

Additional modules are defined in under the extras and can enabled through values in `01-variables.tf`

Additional modules include:
- AWS Load balancer
- Cluster Autoscaler
- Karpenter Autoscaler
- Nginx Ingress (internal and external)
- Users (IAM users with EKS Access)
- EFS fs connected to the EKS cluster using EFS CSI driver



# Deployment
Set Default AWS Profile to ue
```bash
export AWS_PROFILE=test
```

Update values and flags in `01-variable.tf`

Deploy 
```bash
terraform init
terraform plan
```


Update kubeconfg for the new cluster
```bash
aws eks update-kubeconfig --region <your-region> --name  <your-cluster-name>
kubectl get nodes
```

Test users
```bash
aws configure --profile user1
# set access id and secret key
kubectl get nodes
```


#### References
source: https://github.dev/antonputra/tutorials/blob/main/lessons/125/terraform/1-vpc.tf
source: https://github.com/mstiri/eks-cluster/blob/main/cluster.tf#L23

