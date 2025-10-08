using '../main.bicep'

// =========================================
// Basic VM Example
// =========================================
// Windows 11 AVD VM with NSG
// =========================================

// Naming parameters
param purpose = 'avd'
param projectName = 'organimmo'
param environment = 'dev'
param regionCode = 'weu'
param location = 'westeurope'

// VM configuration
param vmSize = 'Standard_D2s_v3'

// Windows 11 AVD image
param imagePublisher = 'microsoftwindowsdesktop'
param imageOffer = 'windows-11'
param imageSku = 'win11-25h2-avd'
param imageVersion = 'latest'

// Disk configuration
param osDiskSizeGB = 127
param osDiskType = 'Premium_LRS'

// Admin credentials
param adminUsername = 'admlocal'
param adminPassword = 'P@ssw0rd123!SecurePassword' // Use Key Vault in production!

// Networking - existing resources
param vnetName = 'vnet-organimmo-dev-weu'
param subnetName = 'snet-avd-dev-weu'
param vnetResourceGroup = 'rg-network-dev-weu'

// Optional NSG - set to empty string to omit NSG
param nsgName = 'nsg-avd-dev-weu'
param nsgResourceGroup = 'rg-network-dev-weu'

// To deploy WITHOUT NSG, uncomment the line below:
// param nsgName = ''

// Tags
param tags = {
  Environment: 'Development'
  Project: 'Organimmo'
  Purpose: 'AVD-SessionHost'
  ManagedBy: 'Bicep'
  CostCenter: 'IT-Development'
}
