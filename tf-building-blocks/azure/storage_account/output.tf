# outputs.tf

# ---- Storage account basics
output "id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "resource_group_name" {
  description = "Resource group of the storage account."
  value       = azurerm_storage_account.this.resource_group_name
}

output "location" {
  description = "Azure region of the storage account."
  value       = azurerm_storage_account.this.location
}

# ---- Endpoints (null if not applicable)
output "primary_endpoints" {
  description = "Primary service endpoints."
  value = {
    blob  = try(azurerm_storage_account.this.primary_blob_endpoint, null)
    queue = try(azurerm_storage_account.this.primary_queue_endpoint, null)
    table = try(azurerm_storage_account.this.primary_table_endpoint, null)
    dfs   = try(azurerm_storage_account.this.primary_dfs_endpoint, null) # Data Lake (HNS)
    web   = try(azurerm_storage_account.this.primary_web_endpoint, null) # Static site
  }
}

# ---- Containers
# Map keyed by container name -> { id, name }
output "containers" {
  description = "Created containers keyed by name."
  value = {
    for name, c in azurerm_storage_container.this :
    name => {
      id   = c.id
      name = c.name
    }
  }
}

# Convenience: list of container names
output "container_names" {
  description = "Names of created containers."
  value       = keys(azurerm_storage_container.this)
}

# ---- Queues
# Map keyed by queue name -> { id, name }
output "queues" {
  description = "Created queues keyed by name."
  value = {
    for name, q in azurerm_storage_queue.this :
    name => {
      id   = q.id
      name = q.name
    }
  }
}

output "queue_names" {
  description = "Names of created queues."
  value       = keys(azurerm_storage_queue.this)
}

# ---- Tables
# Map keyed by table name -> { id, name }
output "tables" {
  description = "Created tables keyed by name."
  value = {
    for name, t in azurerm_storage_table.this :
    name => {
      id   = t.id
      name = t.name
    }
  }
}

output "table_names" {
  description = "Names of created tables."
  value       = keys(azurerm_storage_table.this)
}
