targetScope = 'resourceGroup'

@description('Prefix for resources')
param prefix string = 'simpleAvd'

@description('Location')
param location string = resourceGroup().location

module network './network.bicep' = {
  name: '${prefix}-network'
  params: {
    prefix: prefix
    location: location
  }
}

