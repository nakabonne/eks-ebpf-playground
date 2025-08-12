terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2"
    }
  }
}
