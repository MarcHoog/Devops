variable "name" {
  description = "Globally-unique storage account name (lowercase, 3–24 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3–24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "Azure region (e.g., westeurope)."
  type        = string
  default     = "northeurope"
}

variable "account_tier" {
  description = "Performance tier for the storage account."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be one of: Standard, Premium."
  }
}

variable "account_replication_type" {
  description = "Data replication strategy."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Storage account kind."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage", "Storage"], var.account_kind)
    error_message = "account_kind must be one of: StorageV2, BlobStorage, FileStorage, BlockBlobStorage, Storage."
  }
}

variable "allow_blob_public_access" {
  description = "Whether to allow public blob/container access at the account level."
  type        = bool
  default     = false
}

variable "min_tls_version" {
  description = "Minimum permitted TLS version for requests."
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "min_tls_version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "tags" {
  description = "Common tags applied to all created resources."
  type        = map(string)
  default     = { "deployment" : "terraform" }
}

# ------------------------------
# Children (containers/queues/tables)
# ------------------------------

variable "containers" {
  description = <<EOT
Map of containers to create, keyed by container name.
Each value may override access type and metadata.
Example:
{
  raw    = {}
  public = { access_type = "blob", metadata = { env = "dev" } }
}
EOT
  type = map(object({
    access_type = optional(string, "private") # private | blob | container
    metadata    = optional(map(string), {})
  }))
  default = {}
}

variable "queues" {
  description = "Set of storage queue names to create."
  type        = set(string)
  default     = []
}

variable "tables" {
  description = "Set of storage table names to create."
  type        = set(string)
  default     = []
}
