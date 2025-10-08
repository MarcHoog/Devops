targetScope = 'resourceGroup'

@description('Application/project name for resource naming')
param projectName string

@description('Environment designation')
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environment string

@description('Azure region code for naming (e.g., weu, neu)')
param regionCode string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Tags to apply to all resources')
param tags object = {}

@description('Workspace friendly name')
param workspaceFriendlyName string

@description('Workspace description')
param workspaceDescription string = ''

@description('Host pool configuration')
param hostPools array

@description('Application group configuration')
param applicationGroups array

@description('Start VM on Connect')
param startVMOnConnect bool = false

@description('Purpose/role of the VM for naming')
param vmPurpose string

@description('Virtual machine size')
param vmSize string

@description('Image publisher')
param imagePublisher string

@description('Image offer')
param imageOffer string

@description('Image SKU')
param imageSku string

@description('Image version')
param imageVersion string = 'latest'

@description('OS disk size in GB')
param osDiskSizeGB int = 127

@description('OS disk storage account type')
param osDiskType string = 'StandardSSD_LRS'

@description('Local administrator username')
param adminUsername string

@description('Local administrator password')
@secure()
param adminPassword string

@description('Name of existing virtual network')
param vnetName string

@description('Name of existing subnet')
param subnetName string

@description('Resource group containing the virtual network')
param vnetResourceGroup string

module workspace '../../modules/virtual-desktop/avd-complete/main.bicep' = {
  name: 'avd-workspace-deployment'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    location: location
    workspaceFriendlyName: workspaceFriendlyName
    workspaceDescription: workspaceDescription
    hostPools: hostPools
    applicationGroups: applicationGroups
    startVMOnConnect: startVMOnConnect
    tags: tags
  }
}


module sessionHostVM '../../modules/compute/basic-vm/main.bicep' = {
  name: 'session-host-vm-deployment'
  params: {
     purpose: vmPurpose
     projectName: projectName
     environment: environment
     regionCode: regionCode
     location: location

     vmSize: vmSize
     imagePublisher: imagePublisher
     imageOffer: imageOffer
     imageSku: imageSku
     imageVersion: imageVersion

     osDiskSizeGB: osDiskSizeGB
     osDiskType: osDiskType

     adminUsername: adminUsername
     adminPassword: adminPassword

     vnetName: vnetName
     subnetName: subnetName
     vnetResourceGroup: vnetResourceGroup
     nsgName: ''  // No NSG

     tags: tags
   }
}

@description('Workspace resource ID')
output workspaceId string = workspace.outputs.workspaceId

@description('Workspace name')
output workspaceName string = workspace.outputs.workspaceName

@description('Naming convention examples')
output namingExamples object = workspace.outputs.namingConventionExamples

// Uncomment these outputs after enabling host pools in the module
output hostPoolIds array = workspace.outputs.hostPoolIds
output hostPoolNames array = workspace.outputs.hostPoolNames

// Uncomment these outputs after enabling application groups in the module
output applicationGroupIds array = workspace.outputs.applicationGroupIds
output applicationGroupNames array = workspace.outputs.applicationGroupNames

// Uncomment these outputs after enabling VM deployment
@description('Virtual machine resource ID')
output vmId string = sessionHostVM.outputs.vmId

@description('Virtual machine name')
output vmName string = sessionHostVM.outputs.vmName

@description('VM private IP address')
output vmPrivateIp string = sessionHostVM.outputs.privateIpAddress
