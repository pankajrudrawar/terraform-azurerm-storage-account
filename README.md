# terraform-azurerm-storage-account

Terraform module for an Azure Storage account with secure defaults, blob containers, file shares, lifecycle management and network rules.

[![Validate](https://github.com/pankajrudrawar/terraform-azurerm-storage-account/actions/workflows/validate.yml/badge.svg)](https://github.com/pankajrudrawar/terraform-azurerm-storage-account/actions/workflows/validate.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
![Terraform](https://img.shields.io/badge/terraform-%E2%89%A5%201.5.7-7B42BC?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-module-0078D4)

## Features

- TLS 1.2 minimum, HTTPS only and anonymous blob access disabled by default
- Zone-redundant replication by default
- Blob versioning and soft delete for blobs and containers
- Data Lake Gen2, SFTP and NFSv3 switches
- Containers, file shares and lifecycle management rules defined as maps
- Optional firewall rules and managed identity

## Usage

```hcl
module "storage_account" {
  source = "github.com/pankajrudrawar/terraform-azurerm-storage-account"

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
```

A complete, runnable configuration is in [`examples/basic`](examples/basic).

## Notes

- Set `shared_access_key_enabled = false` to require Microsoft Entra ID. The Terraform provider then needs `storage_use_azuread = true` to manage containers and shares.
- `is_hns_enabled` and `infrastructure_encryption_enabled` cannot be changed after the account is created.
- The azurerm 4.x provider requires a subscription ID, passed in the provider block or through `ARM_SUBSCRIPTION_ID`.

## Module reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| azurerm | >= 4.0, < 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Controls whether any resources are created by this module | `bool` | `true` | no |
| name | Name of the storage account. 3 to 24 characters, lowercase letters and numbers only, globally unique | `string` | n/a | yes |
| resource_group_name | Name of the resource group that holds the storage account | `string` | n/a | yes |
| location | Azure region, for example `eastus2` | `string` | n/a | yes |
| account_kind | Account kind: `StorageV2`, `BlobStorage`, `BlockBlobStorage` or `FileStorage` | `string` | `"StorageV2"` | no |
| account_tier | Performance tier: `Standard` or `Premium` | `string` | `"Standard"` | no |
| account_replication_type | Replication: `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` or `RAGZRS` | `string` | `"ZRS"` | no |
| access_tier | Default access tier for blobs: `Hot` or `Cool`. Only applies to StorageV2 and BlobStorage accounts | `string` | `"Hot"` | no |
| min_tls_version | Minimum TLS version accepted: `TLS1_2` or `TLS1_3` | `string` | `"TLS1_2"` | no |
| https_traffic_only_enabled | Whether only HTTPS traffic is allowed | `bool` | `true` | no |
| allow_nested_items_to_be_public | Whether containers in the account may be configured for anonymous public access | `bool` | `false` | no |
| shared_access_key_enabled | Whether requests may be authorized with the account access keys. Set to false to require Microsoft Entra ID | `bool` | `true` | no |
| default_to_oauth_authentication | Whether the Azure portal defaults to Microsoft Entra ID authorization for data operations | `bool` | `false` | no |
| public_network_access_enabled | Whether public network access is allowed to the account | `bool` | `true` | no |
| cross_tenant_replication_enabled | Whether object replication to and from other Microsoft Entra tenants is allowed | `bool` | `false` | no |
| infrastructure_encryption_enabled | Whether a second layer of encryption (infrastructure encryption) is enabled. Can only be set when the account is created | `bool` | `false` | no |
| is_hns_enabled | Whether the hierarchical namespace is enabled, which turns the account into Data Lake Storage Gen2. Can only be set when the account is created | `bool` | `false` | no |
| nfsv3_enabled | Whether NFSv3 is enabled for blob storage. Requires `is_hns_enabled` and restrictive `network_rules` | `bool` | `false` | no |
| sftp_enabled | Whether SFTP is enabled. Requires `is_hns_enabled` | `bool` | `false` | no |
| identity_type | Managed identity type: `SystemAssigned`, `UserAssigned` or `SystemAssigned, UserAssigned`. Null disables the identity | `string` | `null` | no |
| identity_ids | User-assigned identity IDs. Required when `identity_type` includes `UserAssigned` | `list(string)` | `null` | no |
| blob_properties | Blob service settings | `object` | `{}` | no |
| network_rules | Firewall rules. When null, no network rules block is created and `public_network_access_enabled` is the only control | `object` | `null` | no |
| containers | Map of blob containers keyed by container name | `map(object)` | `{}` | no |
| file_shares | Map of file shares keyed by share name. `quota` is in GiB | `map(object)` | `{}` | no |
| lifecycle_rules | Map of blob lifecycle management rules keyed by rule name | `map(object)` | `{}` | no |
| tags | Tags applied to the storage account | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource ID of the storage account |
| name | Name of the storage account |
| primary_blob_endpoint | Primary endpoint for blob storage |
| primary_file_endpoint | Primary endpoint for file storage |
| primary_dfs_endpoint | Primary endpoint for Data Lake Storage Gen2. Only usable when `is_hns_enabled` is true |
| identity_principal_id | Principal ID of the system-assigned managed identity |
| container_ids | Map of container resource manager IDs keyed by container name |
| file_share_ids | Map of file share resource manager IDs keyed by share name |
<!-- END_TF_DOCS -->

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) first, and ask questions in [Discussions](https://github.com/pankajrudrawar/terraform-azurerm-storage-account/discussions). Run `pre-commit run -a` before opening a pull request. It formats the code, validates it, runs TFLint and refreshes the reference tables above with terraform-docs.

Security problems should be reported privately. See [SECURITY.md](SECURITY.md).

## License

Apache 2.0. See [LICENSE](LICENSE).
