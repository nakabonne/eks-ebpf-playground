# EKS eBPF Playground

This project creates a minimal EKS (Elastic Kubernetes Service) cluster on AWS using Terraform, designed as a playground for eBPF experiments on Kubernetes.

## Prerequisites

1. **AWS CLI** - [Install and configure](https://aws.amazon.com/cli/)
2. **Terraform** - [Install Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
3. **kubectl** - [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
4. **AWS IAM Permissions** - Ensure your AWS credentials have sufficient permissions to create EKS clusters, VPCs, and related resources
5. **direnv** [Install direnv](https://direnv.net/)

## Architecture

This Terraform configuration creates:

- **VPC** with public and private subnets across 3 availability zones
- **EKS Cluster** with managed node groups
- **Security Groups** with appropriate rules
- **IAM Roles** and policies for EKS cluster and node groups
- **NAT Gateway** for private subnet internet access (single NAT for cost optimization)

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd eks-ebpf-playground
   ```

2. **Configure your variables (optional):**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired configuration
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Configure kubectl:**
   ```bash
   aws eks --region ap-northeast-1 update-kubeconfig --name eks-ebpf-playground
   ```

7. **Verify the cluster:**
   ```bash
   kubectl get nodes
   ```

8. **Build and push images**

   ```bash
   make build-push-image
   ```

9. **Apply Kubernetes resources**

   ```bash
   make apply-k8s
   ```

10. See the output from eBPF program

   ```bash
   kubectl exec -it ebpf-sample -- sh -c 'cat /sys/kernel/debug/tracing/trace_pipe'
   ```

## Daily commands

```bash
make apply
```

```bash
make destroy
```


