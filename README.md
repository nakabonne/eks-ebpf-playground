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

## Configuration

### Variables

The following variables can be customized in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region | `ap-northeast-1` |
| `cluster_name` | EKS cluster name | `eks-ebpf-playground` |
| `kubernetes_version` | Kubernetes version | `1.33` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `private_subnets` | Private subnet CIDR blocks | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` |
| `public_subnets` | Public subnet CIDR blocks | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` |
| `node_instance_types` | EC2 instance types for nodes | `["t3.medium"]` |
| `node_group_min_size` | Minimum number of nodes | `1` |
| `node_group_max_size` | Maximum number of nodes | `3` |
| `node_group_desired_size` | Desired number of nodes | `2` |

### Cost Optimization

This configuration includes several cost optimizations:

- Single NAT Gateway instead of one per AZ
- t3.medium instances (suitable for development/testing)
- Minimal node group size
- On-demand instances (consider spot instances for further savings)

## eBPF on EKS

This cluster is configured to support eBPF workloads. Some popular eBPF tools and projects you can experiment with:

- **Cilium** - eBPF-based networking and security
- **Falco** - Runtime security monitoring
- **Pixie** - Kubernetes observability
- **Tetragon** - eBPF-based security observability

## Outputs

After successful deployment, Terraform will output:

- EKS cluster endpoint
- Cluster ARN and name
- VPC and subnet IDs
- kubectl configuration command

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning:** This will permanently delete all resources. Make sure you have backed up any important data.

## Security Considerations

- EKS cluster endpoint is publicly accessible (modify for production)
- IMDSv2 is enforced on EC2 instances
- Private subnets are used for worker nodes
- Security groups follow least-privilege principles

## Troubleshooting

### Common Issues

1. **Insufficient IAM permissions**: Ensure your AWS credentials have the necessary permissions
2. **Resource limits**: Check AWS service quotas for your account
3. **kubectl connection issues**: Verify AWS CLI is configured and run the update-kubeconfig command

### Useful Commands

```bash
# Check cluster status
aws eks describe-cluster --region us-west-2 --name eks-ebpf-playground

# List node groups
aws eks list-nodegroups --region us-west-2 --cluster-name eks-ebpf-playground

# View cluster resources
kubectl get all --all-namespaces
```

