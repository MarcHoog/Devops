import { getResourceAbbreviation } from '../../../shared/naming-conventions.bicep'

@description('Purpose/role of the VM (e.g., avd, app, db) for naming')
@minLength(2)
@maxLength(10)
param purpose string

@description('Application/project name for resource naming')
@minLength(3)
@maxLength(20)
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
@minLength(2)
@maxLength(10)
param regionCode string

@description('Azure region for resource deployment')
param location string = resourceGroup().location

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
@minValue(30)
@maxValue(2048)
param osDiskSizeGB int = 127

@description('OS disk storage account type')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('Local administrator username')
@minLength(1)
@maxLength(20)
param adminUsername string

@description('Local administrator password')
@secure()
@minLength(12)
param adminPassword string

@description('Name of existing virtual network')
param vnetName string

@description('Name of existing subnet')
param subnetName string

@description('Resource group containing the virtual network')
param vnetResourceGroup string = resourceGroup().name

@description('Name of existing network security group (empty string for none)')
param nsgName string = ''

@description('Resource group containing the network security group')
param nsgResourceGroup string = vnetResourceGroup

@description('Tags to apply to all resources')
param tags object = {}

// ============================================
// VARIABLES
// ============================================

var vmName = '${getResourceAbbreviation('virtualMachine')}-${purpose}-${projectName}-${environment}-${regionCode}'
var nicName = '${getResourceAbbreviation('networkInterface')}-${purpose}-${projectName}-${environment}-${regionCode}'

// Computer name must be max 15 characters for Windows
var computerName = take('${purpose}-${projectName}', 15)

var hasNsg = nsgName != ''

// ============================================
// EXISTING RESOURCE REFERENCES
// ============================================

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: subnetName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' existing = if (hasNsg) {
  name: nsgName
  scope: resourceGroup(nsgResourceGroup)
}

// ============================================
// NETWORK INTERFACE
// ============================================

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    networkSecurityGroup: hasNsg ? {
      id: nsg.id
    } : null
  }
}

// ============================================
// VIRTUAL MACHINE
// ============================================

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: 'Delete'
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

// ============================================
// OUTPUTS
// ============================================

@description('Virtual machine resource ID')
output vmId string = vm.id

@description('Virtual machine name')
output vmName string = vm.name

@description('Network interface resource ID')
output nicId string = nic.id

@description('Private IP address assigned to the VM')
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
