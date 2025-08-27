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
  server_name  = "bob"
  image        = "ubuntu-24.04"
  server_type  = "cx22"
  location     = "nbg1"
  ssh_keys     = ["bubble", "ansible"]
  ipv4_enabled = true
  labels = {
    "k3s" : "controller"
    "k3s" : "flux"
    "arch" : "x86"
  }
}
