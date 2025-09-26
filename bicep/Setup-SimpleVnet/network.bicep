param prefix string
param location string

@description('Vnet address space')
param vnetAddressSpace string = '10.10.0.0/16'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.10.1.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: '${prefix}-subnet'
        properties: {
        addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
output vnetId string = vnet.id
