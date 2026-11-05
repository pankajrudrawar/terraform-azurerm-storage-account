output "id" {
  description = "Resource ID of the storage account"
  value       = try(azurerm_storage_account.this[0].id, null)
}

output "name" {
  description = "Name of the storage account"
  value       = try(azurerm_storage_account.this[0].name, null)
}

output "primary_blob_endpoint" {
  description = "Primary endpoint for blob storage"
  value       = try(azurerm_storage_account.this[0].primary_blob_endpoint, null)
}

output "primary_file_endpoint" {
  description = "Primary endpoint for file storage"
  value       = try(azurerm_storage_account.this[0].primary_file_endpoint, null)
}

output "primary_dfs_endpoint" {
  description = "Primary endpoint for Data Lake Storage Gen2. Only usable when `is_hns_enabled` is true"
  value       = try(azurerm_storage_account.this[0].primary_dfs_endpoint, null)
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity"
  value       = try(azurerm_storage_account.this[0].identity[0].principal_id, null)
}

output "container_ids" {
  description = "Map of container resource manager IDs keyed by container name"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "file_share_ids" {
  description = "Map of file share resource manager IDs keyed by share name"
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}
