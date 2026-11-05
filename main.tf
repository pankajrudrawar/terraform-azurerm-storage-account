################################################################################
# Storage account
################################################################################

resource "azurerm_storage_account" "this" {
  count = var.create ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = contains(["StorageV2", "BlobStorage"], var.account_kind) ? var.access_tier : null

  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  public_network_access_enabled     = var.public_network_access_enabled
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  is_hns_enabled                    = var.is_hns_enabled
  nfsv3_enabled                     = var.nfsv3_enabled
  sftp_enabled                      = var.sftp_enabled

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  blob_properties {
    versioning_enabled  = var.blob_properties.versioning_enabled
    change_feed_enabled = var.blob_properties.change_feed_enabled

    dynamic "delete_retention_policy" {
      for_each = var.blob_properties.delete_retention_days > 0 ? [1] : []

      content {
        days = var.blob_properties.delete_retention_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.blob_properties.container_delete_retention_days > 0 ? [1] : []

      content {
        days = var.blob_properties.container_delete_retention_days
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []

    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

################################################################################
# Containers and file shares
################################################################################

resource "azurerm_storage_container" "this" {
  for_each = var.create ? var.containers : {}

  name                  = each.key
  storage_account_name  = azurerm_storage_account.this[0].name
  container_access_type = each.value.container_access_type
  metadata              = each.value.metadata
}

resource "azurerm_storage_share" "this" {
  for_each = var.create ? var.file_shares : {}

  name                 = each.key
  storage_account_name = azurerm_storage_account.this[0].name
  quota                = each.value.quota
  access_tier          = each.value.access_tier
  enabled_protocol     = each.value.enabled_protocol
  metadata             = each.value.metadata
}

################################################################################
# Lifecycle management
################################################################################

resource "azurerm_storage_management_policy" "this" {
  count = var.create && length(var.lifecycle_rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.this[0].id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.key
      enabled = rule.value.enabled

      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }
      }
    }
  }
}
