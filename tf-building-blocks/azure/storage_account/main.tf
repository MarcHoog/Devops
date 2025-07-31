terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">= 3.110.0" }
  }
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  min_tls_version = var.min_tls_version
  tags            = var.tags
}

# Containers
resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.access_type
  metadata              = each.value.metadata
}

# Queues
resource "azurerm_storage_queue" "this" {
  for_each             = var.queues
  name                 = each.value
  storage_account_name = azurerm_storage_account.this.name
}

# Tables
resource "azurerm_storage_table" "this" {
  for_each             = var.tables
  name                 = each.value
  storage_account_name = azurerm_storage_account.this.name
}

output "id" { value = azurerm_storage_account.this.id }
output "name" { value = azurerm_storage_account.this.name }
output "primary_blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
output "container_names" { value = keys(azurerm_storage_container.this) }
output "queue_names" { value = toset([for q in azurerm_storage_queue.this : q.name]) }
output "table_names" { value = toset([for t in azurerm_storage_table.this : t.name]) }
