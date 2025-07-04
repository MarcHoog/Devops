terraform {

  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.49.1"
    }
  }


  backend  "s3" {
  }
}



module "singleNodeK3s" {
  source       = "git::https://github.com/MarcHoog/devops.git//terraform/mod/hetzner/server?ref=main"
  server_name = "boeing747"
  image        = "ubuntu-24.04"
  server_type  = "cx22"
  location     = "nbg1" # Example location; adjust as needed
  ssh_keys     = ["bubble", "ansible"]
  ipv4_enabled = true
  labels = {
    "k3s": "controller"
    "k3s": "flux_controller"
    "arch": "x86"
  }
}
