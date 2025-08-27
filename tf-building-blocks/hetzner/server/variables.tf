variable "server_name" {
  description = "Name of the Hetzner server"
  type        = string
  default     = ""

}

variable "image" {
  description = "The image slug to use for the server (e.g., ubuntu-22.04)"
  type        = string
}

variable "server_type" {
  description = "The type of the server (e.g., cx31)"
  type        = string
}

variable "location" {
  description = "Hetzner location (e.g., nbg1, fsn1)"
  type        = string
  validation {
    condition     = contains(["nbg1", "fsn1"], var.location)
    error_message = "The location must be one of: nbg1, fsn1"
  }
}

variable "ssh_keys" {
  description = "List of SSH key names (as registered in Hetzner) to add to the server"
  type        = list(string)
  default     = []
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 0
}


variable "ipv4_enabled" {
  description = "Enable IPv4 for the server(s)"
  type        = bool
  default     = false
}

variable "ipv6_enabled" {
  description = "Enable IPv6 for the server(s)"
  type        = bool
  default     = false

}


variable "labels" {
  description = "Labels to attach to the server"
  type        = map(any)
  default     = {}
}

variable "enable_firewall" {
  description = "Whether to create and attach a Hetzner Firewall to the server"
  type        = bool
  default     = false
}

variable "firewall_name" {
  description = "Optional name for the firewall; defaults to \"<server_name>-fw\" if null"
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = "Map of firewall rules keyed by name for easy definition. Each rule requires direction, protocol, ips and optionally port and description."
  type = map(object({
    direction   = string           # "in" or "out"
    protocol    = string           # one of tcp, udp, icmp, gre, esp
    ips         = list(string)     # source_ips (for in) or destination_ips (for out)
    port        = optional(string) # required for tcp/udp (e.g., "22", "80-90", "any"); omit for icmp/gre/esp
    description = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for r in values(var.firewall_rules) :
      contains(["in", "out"], lower(r.direction))
    ])
    error_message = "Each firewall rule.direction must be either 'in' or 'out'."
  }

  validation {
    condition = alltrue([
      for r in values(var.firewall_rules) :
      contains(["tcp", "udp", "icmp", "gre", "esp"], lower(r.protocol))
    ])
    error_message = "Each firewall rule.protocol must be one of: tcp, udp, icmp, gre, esp."
  }

  validation {
    condition = alltrue([
      for r in values(var.firewall_rules) :
      contains(["tcp", "udp"], lower(r.protocol)) ? try(r.port != null && r.port != "", false) : true
    ])
    error_message = "For tcp/udp rules, 'port' must be set (e.g., '22', '80-90', or 'any')."
  }
}
