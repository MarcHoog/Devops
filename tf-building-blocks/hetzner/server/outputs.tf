output "server_id" {
  description = "The ID of the created Hetzner server"
  value       = hcloud_server.server[*].id
}

output "firewall_id" {
  description = "The ID of the created Hetzner firewall (if enabled)"
  value       = try(hcloud_firewall.this[0].id, null)
}

output "firewall_name" {
  description = "The name of the Hetzner firewall (if enabled)"
  value       = local.firewall_enabled ? local.firewall_name : null
}
