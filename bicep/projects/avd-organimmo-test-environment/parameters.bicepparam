using './main.bicep'

// =========================================
// Naming and Location
// =========================================
param projectName = 'organimoTesting'
param environment = 'prd'
param regionCode = 'we'
param location = 'westeurope'

// =========================================
// AVD Workspace Configuration
// =========================================
param workspaceFriendlyName = 'Organimmo Development Workspace'
param workspaceDescription = 'Azure Virtual Desktop development environment for testing of Organimmo products'

param hostPools = [
  {
    name: 'devbox'
    type: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 3
    preferredAppGroupType: 'Desktop'
  }
]

param applicationGroups = [
  {
    name: 'desktop'
    type: 'Desktop'
    friendlyName: 'Organimmo Development Desktop'
    description: 'Full desktop access for development and testing'
    hostPoolName: 'devbox'
  },{
    name: 'remoteapp'
    type: 'RemoteApp'
    friendlyName: 'Organimmo Development Apps'
    description: 'Application access to specific apps for testing'
    hostPoolName: 'devbox'
  }
]

param startVMOnConnect = true

// =========================================
// VM Configuration
// =========================================
param vmPurpose = 'avd'
param vmSize = 'Standard_D2s_v3'

// Windows 11 AVD image
param imagePublisher = 'microsoftwindowsdesktop'
param imageOffer = 'windows-11'
param imageSku = 'win11-25h2-avd'
param imageVersion = 'latest'

// Disk configuration
param osDiskSizeGB = 127
param osDiskType = 'StandardSSD_LRS'

// Admin credentials
param adminUsername = 'admlocal'
param adminPassword = '' // Set during deployment with --parameters adminPassword='YourSecurePassword'

// =========================================
// Network Configuration
// =========================================
param vnetName = 'vnet_parte'
param subnetName = 'servernet'
param vnetResourceGroup = 'rg_vnet'
// No NSG needed

// =========================================
// Tags
// =========================================
param tags = {
  Environment: 'prd'
  Project: 'organimoTesting'
  CostCenter: 'Organimmo'
  ManagedBy: 'Bicep'
}
