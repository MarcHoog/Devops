terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0"
    }
  }


  backend "azurerm" {
  }
}

module "resourcegroup" {
  source = "git::https://github.com/MarcHoog/devops.git//tf-building-blocks/azure/resource_group?ref=main"
  name   = "test123"
}
