output "server_id" {
  description = "The ID of the created Hetzner server"
  value       = hcloud_server.server[*].id
}