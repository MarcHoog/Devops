terraform {

  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.49.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
  }


  backend "azurerm" {
  }
}



module "nixOS" {
  source       = "git::https://github.com/MarcHoog/devops.git//tf-building-blocks/hetzner/server?ref=main"

  server_name  = "ubuntox-01"
  image        = "ubuntu-24.04" 
  server_type  = "cx22"
  location     = "nbg1"
  ssh_keys     = ["bubble", "ansible"]
  ipv4_enabled = true

  # Labels
  labels = {
    "k3s" : "controller"
    "k3s" : "flux"
    "arch" : "x86"
  }

  # Firewall
  enable_firewall = true
  firewall_name   = "ubuntox-01-fw"
  firewall_rules = {
    ssh_in = {
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      ips         = ["0.0.0.0/0", "::/0"]
      description = "Allow SSH"
    }
    http_in = {
      direction = "in"
      protocol  = "tcp"
      port      = "80"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow HTTP"
    }
    https_in = {
      direction = "in"
      protocol  = "tcp"
      port      = "443"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow HTTPS"
    }
    icmp_in = {
      direction = "in"
      protocol  = "icmp"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow ICMP"
    }
  }
}
