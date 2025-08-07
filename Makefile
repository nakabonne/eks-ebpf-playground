.PHONY: help init plan apply destroy validate fmt check clean

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	terraform init

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

plan: ## Show Terraform execution plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy Terraform-managed infrastructure
	terraform destroy

check: validate fmt ## Run validation and formatting checks

clean: ## Clean Terraform files
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfplan

config-kubectl: ## Configure kubectl with the EKS cluster
	@echo "Configuring kubectl..."
	@CLUSTER_NAME=$$(terraform output -raw cluster_name 2>/dev/null || echo "eks-ebpf-playground"); \
	REGION=$$(terraform output -raw region 2>/dev/null || echo "us-west-2"); \
	aws eks --region $$REGION update-kubeconfig --name $$CLUSTER_NAME

status: ## Show cluster status
	@echo "Cluster status:"
	kubectl get nodes
	@echo ""
	@echo "Namespaces:"
	kubectl get namespaces
	@echo ""
	@echo "All resources:"
	kubectl get all --all-namespaces
