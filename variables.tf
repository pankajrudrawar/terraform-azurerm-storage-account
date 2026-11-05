variable "create" {
  description = "Controls whether any resources are created by this module"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the storage account. 3 to 24 characters, lowercase letters and numbers only, globally unique"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "name must be 3 to 24 characters and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the storage account"
  type        = string
}

variable "location" {
  description = "Azure region, for example `eastus2`"
  type        = string
}

variable "account_kind" {
  description = "Account kind: `StorageV2`, `BlobStorage`, `BlockBlobStorage` or `FileStorage`"
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Performance tier: `Standard` or `Premium`"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication: `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` or `RAGZRS`"
  type        = string
  default     = "ZRS"
}

variable "access_tier" {
  description = "Default access tier for blobs: `Hot` or `Cool`. Only applies to StorageV2 and BlobStorage accounts"
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "Minimum TLS version accepted: `TLS1_2` or `TLS1_3`"
  type        = string
  default     = "TLS1_2"
}

variable "https_traffic_only_enabled" {
  description = "Whether only HTTPS traffic is allowed"
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Whether containers in the account may be configured for anonymous public access"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Whether requests may be authorized with the account access keys. Set to false to require Microsoft Entra ID"
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Whether the Azure portal defaults to Microsoft Entra ID authorization for data operations"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed to the account"
  type        = bool
  default     = true
}

variable "cross_tenant_replication_enabled" {
  description = "Whether object replication to and from other Microsoft Entra tenants is allowed"
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Whether a second layer of encryption (infrastructure encryption) is enabled. Can only be set when the account is created"
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Whether the hierarchical namespace is enabled, which turns the account into Data Lake Storage Gen2. Can only be set when the account is created"
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Whether NFSv3 is enabled for blob storage. Requires `is_hns_enabled` and restrictive `network_rules`"
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Whether SFTP is enabled. Requires `is_hns_enabled`"
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "Managed identity type: `SystemAssigned`, `UserAssigned` or `SystemAssigned, UserAssigned`. Null disables the identity"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "User-assigned identity IDs. Required when `identity_type` includes `UserAssigned`"
  type        = list(string)
  default     = null
}

variable "blob_properties" {
  description = "Blob service settings"
  type = object({
    versioning_enabled              = optional(bool, true)
    change_feed_enabled             = optional(bool, false)
    delete_retention_days           = optional(number, 7)
    container_delete_retention_days = optional(number, 7)
  })
  default = {}
}

variable "network_rules" {
  description = "Firewall rules. When null, no network rules block is created and `public_network_access_enabled` is the only control"
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "containers" {
  description = "Map of blob containers keyed by container name"
  type = map(object({
    container_access_type = optional(string, "private")
    metadata              = optional(map(string), {})
  }))
  default = {}
}

variable "file_shares" {
  description = "Map of file shares keyed by share name. `quota` is in GiB"
  type = map(object({
    quota            = number
    access_tier      = optional(string)
    enabled_protocol = optional(string, "SMB")
    metadata         = optional(map(string), {})
  }))
  default = {}
}

variable "lifecycle_rules" {
  description = "Map of blob lifecycle management rules keyed by rule name"
  type = map(object({
    enabled                    = optional(bool, true)
    prefix_match               = optional(list(string), [])
    blob_types                 = optional(list(string), ["blockBlob"])
    tier_to_cool_after_days    = optional(number)
    tier_to_archive_after_days = optional(number)
    delete_after_days          = optional(number)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the storage account"
  type        = map(string)
  default     = {}
}
