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


module "WindowsNodePoc" {
  source       = "git::https://github.com/MarcHoog/devops.git//tf-building-blocks/hetzner/server?ref=main"

  server_name  = "boeing-777"
  image        = "ubuntu-24.04" 
  server_type  = "cx32"
  location     = "nbg1"
  ssh_keys     = ["bubble", "ansible"]
  ipv4_enabled = true

  # Labels
  labels = {
    "arch" : "x86"
  }

  enable_firewall = true
  firewall_name   = "boeing-777-fw"
  firewall_rules = {
    ssh_in = {
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      ips         = ["188.245.213.214"]
      description = "Allow SSH"
    }
    icmp_in = {
      direction = "in"
      protocol  = "icmp"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow ICMP"
    }
  }
}



module "TalosNode1" {
  source       = "git::https://github.com/MarcHoog/devops.git//tf-building-blocks/hetzner/server?ref=main"

  server_name  = "boeing-737"
  image        = "ubuntu-24.04" 
  server_type  = "cx32"
  location     = "nbg1"
  ssh_keys     = ["bubble", "ansible"]
  ipv4_enabled = true

  # Labels
  labels = {
    "arch" : "x86"
  }

  enable_firewall = true
  firewall_name   = "boeing-737-fw"
  firewall_rules = {
    ssh_in = {
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      ips         = ["0.0.0.0/0", "::/0"]
      description = "Allow SSH"
    }
    wireguard_in = {
      direction = "in"
      protocol  = "udp"
      port      = "51820"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow WireGuard"
    }
    icmp_in = {
      direction = "in"
      protocol  = "icmp"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow ICMP"
    }
  }
}
