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

# Optional firewall and attachment
resource "hcloud_firewall" "this" {
  count = local.firewall_enabled ? 1 : 0

  name = local.firewall_name

  dynamic "rule" {
    for_each = local.firewall_rules_in_with_port
    content {
      direction   = "in"
      protocol    = lower(rule.value.protocol)
      port        = rule.value.port
      source_ips  = rule.value.ips
      description = try(rule.value.description, null)
    }
  }

  dynamic "rule" {
    for_each = local.firewall_rules_in_no_port
    content {
      direction   = "in"
      protocol    = lower(rule.value.protocol)
      source_ips  = rule.value.ips
      description = try(rule.value.description, null)
    }
  }

  dynamic "rule" {
    for_each = local.firewall_rules_out_with_port
    content {
      direction       = "out"
      protocol        = lower(rule.value.protocol)
      port            = rule.value.port
      destination_ips = rule.value.ips
      description     = try(rule.value.description, null)
    }
  }

  dynamic "rule" {
    for_each = local.firewall_rules_out_no_port
    content {
      direction       = "out"
      protocol        = lower(rule.value.protocol)
      destination_ips = rule.value.ips
      description     = try(rule.value.description, null)
    }
  }
}

resource "hcloud_firewall_attachment" "server" {
  count = local.firewall_enabled ? 1 : 0

  firewall_id = hcloud_firewall.this[0].id
  server_ids  = [hcloud_server.server.id]
}
