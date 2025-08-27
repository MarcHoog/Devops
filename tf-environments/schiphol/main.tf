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



module "TalosNode1" {
  source       = "git::https://github.com/MarcHoog/devops.git//tf-building-blocks/hetzner/server?ref=main"

  server_name  = "boeing-737"
  image        = "312961706" 
  server_type  = "cx32"
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
  firewall_name   = "boeing-737-fw"
  firewall_rules = {
    ssh_in = {
      direction   = "in"
      protocol    = "tcp"
      port        = "6443"
      ips         = ["0.0.0.0/0", "::/0"]
      description = "Allow SSH"
    }
    talos_management = {
      direction = "in"
      protocol = "tcp"
      port = "50000"
      ips = ["91.180.39.10"]
      description = "Allow Talos Management plane"
    }

    icmp_in = {
      direction = "in"
      protocol  = "icmp"
      ips       = ["0.0.0.0/0", "::/0"]
      description = "Allow ICMP"
    }
  }
}
