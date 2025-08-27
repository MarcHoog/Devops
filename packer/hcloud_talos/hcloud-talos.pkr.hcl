# talos-hcloud.pkr.hcl
packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1"
    }
  }
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "talos_version" {
  type    = string
  default = "v1.10.6"  # update to latest release if needed
}

variable "arch" {
  type    = string
  default = "amd64"
}

variable "server_type" {
  type    = string
  default = "cx22"     # pick VM size
}

variable "server_location" {
  type    = string
  default = "hel1"
}

locals {
  # Prebuilt Hetzner Cloud Talos raw disk image from Talos factory
  image = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/${var.talos_version}/hcloud-${var.arch}.raw.xz"
}

source "hcloud" "talos" {
  token       = var.hcloud_token
  rescue      = "linux64"       # boot in rescue mode so we can write disk
  image       = "debian-11"     # temp OS (will be wiped)
  location    = var.server_location
  server_type = var.server_type
  ssh_username = "root"

  snapshot_name   = "talos-${var.arch}-${var.talos_version}"
  snapshot_labels = {
    type    = "infra"
    os      = "talos"
    version = var.talos_version
    arch    = var.arch
  }
}

build {
  name    = "talos-hcloud"
  sources = ["source.hcloud.talos"]

  provisioner "shell" {
    inline = [
      "apt-get update && apt-get install -y wget xz-utils",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda bs=4M conv=fsync oflag=direct",
      "sync"
    ]
  }
}
