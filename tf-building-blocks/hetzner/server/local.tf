locals {
  firewall_enabled = var.enable_firewall
  firewall_name    = coalesce(var.firewall_name, "${var.server_name}-fw")

  firewall_rules_all = var.enable_firewall ? var.firewall_rules : {}

  # Split rules for correct attribute mapping and presence of port
  firewall_rules_in_with_port = {
    for k, r in local.firewall_rules_all : k => r
    if lower(r.direction) == "in" && contains(["tcp", "udp"], lower(r.protocol))
  }
  firewall_rules_in_no_port = {
    for k, r in local.firewall_rules_all : k => r
    if lower(r.direction) == "in" && !contains(["tcp", "udp"], lower(r.protocol))
  }
  firewall_rules_out_with_port = {
    for k, r in local.firewall_rules_all : k => r
    if lower(r.direction) == "out" && contains(["tcp", "udp"], lower(r.protocol))
  }
  firewall_rules_out_no_port = {
    for k, r in local.firewall_rules_all : k => r
    if lower(r.direction) == "out" && !contains(["tcp", "udp"], lower(r.protocol))
  }
}
