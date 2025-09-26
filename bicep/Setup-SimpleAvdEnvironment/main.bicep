targetScope = 'resourceGroup'

@description('Prefix for resources')
param prefix string = 'simpleAvd'

@description('Location')
param location string = resourceGroup().location

@description('Definition of an application group')
type appGroupConfig = {
  @description('Short name suffix for the app group (used in resource name)')
  name: string

  @description('Type of the application group')
  type: string

  @description('Display name in the portal / client')
  friendlyName: string

  @description('Description of the app group')
  description: string
}

@description('List of application groups to create')
param appGroups appGroupConfig[]


module hostPool './hostpool.bicep' = {
  name: '${prefix}-hostpool'
  params: {
    prefix: prefix
    location: location
  }
}

module appGroup './appgroup.bicep' = {
  name: '${prefix}-appgroup'
  params: {
    prefix: prefix
    location: location
    hostPoolId: hostPool.outputs.id
    appGroups: appGroups
  }
}

module workspace './workspace.bicep' = {
  name: '${prefix}-workspace'
  params: {
    prefix: prefix
    location: location
    applicationGroupReferences: appGroup.outputs.appGroupIds
  }
}
