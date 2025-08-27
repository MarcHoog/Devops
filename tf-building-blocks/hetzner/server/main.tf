resource "hcloud_server" "server" {
  name        = var.server_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_keys
  labels      = var.labels

  public_net {
    ipv4_enabled = var.ipv4_enabled
    ipv6_enabled = var.ipv6_enabled
  }

  lifecycle {
    ignore_changes = [
      image,
      labels,
    ]
  }
}

# Create a volume only if volume_size > 0
resource "hcloud_volume" "storage" {
  count    = var.volume_size > 0 ? 1 : 0
  name     = "${var.server_name}-vl"
  size     = var.volume_size
  location = var.location
}

resource "hcloud_volume_attachment" "attachment" {
  count     = var.volume_size > 0 ? 1 : 0
  server_id = hcloud_server.server.id
  volume_id = hcloud_volume.storage[0].id
}