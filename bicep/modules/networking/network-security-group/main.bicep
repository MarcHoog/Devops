@description('Name of the network security group')
param nsgName string

@description('Location for the network security group')
param location string = resourceGroup().location

@description('Security rules for the NSG')
param securityRules array = []

@description('Tags to apply to the network security group')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        description: contains(rule, 'description') ? rule.description : ''
        protocol: rule.protocol
        sourcePortRange: contains(rule, 'sourcePortRange') ? rule.sourcePortRange : '*'
        destinationPortRange: contains(rule, 'destinationPortRange') ? rule.destinationPortRange : null
        destinationPortRanges: contains(rule, 'destinationPortRanges') ? rule.destinationPortRanges : []
        sourceAddressPrefix: contains(rule, 'sourceAddressPrefix') ? rule.sourceAddressPrefix : '*'
        destinationAddressPrefix: contains(rule, 'destinationAddressPrefix') ? rule.destinationAddressPrefix : '*'
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
}

@description('Resource ID of the network security group')
output nsgId string = nsg.id

@description('Name of the network security group')
output nsgName string = nsg.name
