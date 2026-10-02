# Floci with Terraform

## Aim of the Project
The aim of this project was to create a terraform config example that used the Floci AWS emulator. The configuration will create a cluster in EKS to be used as a temporary environment, deploy some applications to the cluster and record metadata about the environment in S3. Variables will be used to define what and how many applications are to be deployed. 

The terraform workspace will use a remote backend in S3 simulated in Floci.

The terraform commands required will be accessible using the env.sh script.

It can be run entirely within containers and would not require local installations of Floci or Terraform. 

---

## Platform Components

| Component | Image | Purpose |
|---|---|---|
| Terraform | hashicorp/terraform:latest | IaC Tool |
| Floci | floci/floci:latest | AWS Emulator |
| Floci UI | floci/floci-ui:latest | UI Component for the Emulator|

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/ThomasMOwen/floci-terraform.git
cd floci-terraform
```

### 2. Create the floci 

```bash
docker compose up
```

This creates the floci instance and the network that the emulation will run in.

### 3. Configute AWS CLI

```
aws configure --profile floci
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
default output format [None]: json

```

### 4. Create Bucket for S3 Backend

The bucket for the S3 backend will need to be available so that terraform init can take place
```
aws --endpoint-url=http://localhost:4566 --profile=floci s3 mb s3://tfstate
```

### 5. Initialize Terraform
```
make init
```

### 6. Access Floci

| URL | Action |
|---|---|
|`http://localhost:4566` | Click Open Floci UI |
|`http://localhost:4500` | Access the Floci UI | 


### 7. Run Terraform Commands
env.sh is a script that will run terraform commands to create and destroy a environment.\
Update env.tfvars with the name of the cluster, applications to run and the owner. Script usage:

```
usage="$0 [-h] [-o s] [-f s] -- script to run terraform commands against AWS emulated environment

where:
    -h : show help text
    -o : define the operation to perform. Operations: plan, apply, apply-auto-approve, destroy
    -f : specify the tfvars file to use for the operation"
```
### 8. Access the cluster

Set up Kubectl

```
aws eks update-kubeconfig --name {cluster-name}
nano ~/.kube/config #Ensure exec command for aws is pointing to the aws binary
kubectl get namespaces
kubectl get pods -n {created-namespace}
```
---

## Repository Structure

```
terraform-modules/
|
├── modules/                   # Module configurations
│   ├── pods/                  # Configuration to deploy applications to the EKS cluster
│   ├── network/               # Configuration for networking required by the EKS cluster
│   ├── cluster/               # Configuration for the EKS cluster
│   └── s3/                    # Configuration for bucket and object hosting environment metadata
│
├── main.tf                    # Main configuration for temporary environment
├── variables.tf               # Variable definitions for the main configuration
├── terraform.tf               # Terraform configuration
├── env.tfvars                 # Variable file for the terraform configuration
├── env.sh                     # Script to run terraform commands
├── compose.yml                # Compose file to set up the floci instance
├── makefile                   # Makefile for running commands used in workflow locally, mostly for terraform commands
└── README.md
```

---

## Key Concepts Demonstrated

### Terraform Modules

Modules were created to abstract AWS networking, cluster creation and app deployment on to the EKS cluster. Variables were passed to the modules and outputs captured from the network module used by the cluster. \
Using env.tfvars to define applications means pods can be added, removed, or changed without touching the Terraform config itself.

### AWS Networking

The EKS cluster was provisioned with it's own VPC, subnets across different AZs and security group.

### Kubernetes Deployments to EKS

The pods module can deploy a dynamic amount of applications to the EKS cluster which are accessible through Kubectl.

---



## What I'd Do Next

- **IPV6 Networking** - Currently VPC is limited to IPV4, extending to IPV6 would reflect production more accurately.
- **More sophisticated access controls** - there are further access controls to experiment with such as bucket ACLs.
- **ArgoCD intergration experimentation** - it would be interesting to see if ArgoCD could be used for application deployment instead of the kubernetes provider.

---

## Known Limitations

- Kubernetes access is set to insecure - Certficate Authority is emulated and is causing a mismatch with the certificate found in the K3s container. To workaround x509 verification failures "insecure" was set to true.
