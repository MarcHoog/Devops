targetScope = 'subscription'

@description('Resource Group name')
param rgName string


@description('Reader group to attach to this RG')
param readerGroupObjectId string 

@description('Optional tags')
param tags object = {
  'x-created-by': 'bicep'
}

var deployLocation = deployment().location

module rg 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'rg-${rgName}'
  params: {
    name: rgName
    location: deployLocation
    tags: tags
    roleAssignments: [
      {
        principalId: readerGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Reader'
        description: 'Read-only access for the group'
      }
    ]
  }
}
