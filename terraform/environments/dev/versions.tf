terraform {
  required_version = ">= 1.16.0"

  backend "azurerm" {
    resource_group_name  = "rg-enterprise-gitops-tfstate-brazilsouth"
    storage_account_name = "stentgitopstf29xa5r"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}