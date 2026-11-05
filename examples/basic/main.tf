terraform {
  required_version = ">= 1.5.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "Azure subscription ID. Falls back to the ARM_SUBSCRIPTION_ID environment variable when null"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "storage_account_name" {
  description = "Globally unique storage account name"
  type        = string
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-example"
  location = var.location
}

module "storage_account" {
  source = "../.."

  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_replication_type = "ZRS"
  identity_type            = "SystemAssigned"

  containers = {
    raw       = {}
    processed = {}
  }

  file_shares = {
    shared = { quota = 100 }
  }

  lifecycle_rules = {
    tier-and-expire = {
      prefix_match               = ["raw/"]
      tier_to_cool_after_days    = 30
      tier_to_archive_after_days = 90
      delete_after_days          = 365
    }
  }

  tags = {
    Environment = "example"
    ManagedBy   = "terraform"
  }
}

output "blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}
