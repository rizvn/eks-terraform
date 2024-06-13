This terraform project will create a ready to use cluster with the necessary addons and features.

The following tapology will be deployed:

![Diagram](docs/eks-terraform.svg)

- VPC with 
  - 3 public subnets
  - 3 private subnets
  - NAT Gateway
  

-  EKS cluster with
   - OIDC enabled for IRSA
   - With Addons for 
     - CoreDNS
     - VPC CNI with Network policy support
     - Kube-proxy

- Ingress-only nodegroup 
- General nodegroup

Additional modules are defined under the extras and can enabled through values in `01-variables.tf`

Additional modules are configured through `04-extras.tf`. The following modules are available:
- AWS Load balancer
- Cluster Autoscaler
- Karpenter Autoscaler
- Nginx Ingress (internal and external)
- Users (IAM users with EKS Access)
- EFS fs connected to the EKS cluster using EFS CSI driver
- EBS CSI driver for gp3 volumes
- AWS VPN Client for remote access to private subnets



# Deployment
Set Default AWS Profile to use. This should be the profile that has the necessary permissions to create the resources in the account
```bash
export AWS_PROFILE=test
```

Update values and flags in `01-variable.tf`

Deploy 
```bash
terraform init
terraform apply
```


Update local kubeconfig for the new cluster
```bash
aws eks update-kubeconfig --region <your-region> --name  <your-cluster-name>
```

List nodes to test connectivity
```bash
kubectl get nodes
````

Test users (if users module is enabled)
```bash
- accesskey and secretkey are generated for the user

configure the user profile
```bash
aws configure --profile user1
```

Create assume profile for user 1
```bash
vim ~/.aws/config
````

```bash
[profile eks-admin]
role_arn = arn:aws:iam::<your-account-number>:role/eks-admin
source_profile = user1
``


# set access id and secret key
kubectl get nodes
```


Client vpn if deployed
```bash
sudo openvpn \
  --config ~/Downloads/config.ovpn \
  --ca certs/ca.crt \
  --cert certs/client.crt \
  --key certs/client.key
```

#### References
- https://github.com/antonputra/tutorials/blob/main/lessons/125/terraform/1-vpc.tf
- https://github.com/mstiri/eks-cluster/blob/main/cluster.tf

