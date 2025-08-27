Naming scheme
S# -> Server Amounts
v -> Volumes attached to the servers
F firewall attached to it

Firewall support
- enable by setting `enable_firewall = true` in the module call
- optionally set `firewall_name` (defaults to `<server_name>-fw`)
- define rules via `firewall_rules` map keyed by rule name

Example `firewall_rules` map
```
firewall_rules = {
  ssh_in = {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    ips         = ["0.0.0.0/0", "::/0"]
    description = "Allow SSH"
  }
  http_in = {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    ips         = ["0.0.0.0/0", "::/0"]
  }
  icmp_out = {
    direction = "out"
    protocol  = "icmp"
    ips       = ["0.0.0.0/0", "::/0"]
  }
}
```
