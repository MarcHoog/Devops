// Azure Virtual Desktop - Complete Deployment Module
// This module deploys a complete AVD environment including:
// - Host Pools (configurable count and type)
// - Application Groups (Desktop and/or RemoteApp)
// - Workspace (with all application groups)

import { getResourceAbbreviation } from '../../../shared/naming-conventions.bicep'

@description('Application/project name for resource naming (lowercase, no spaces)')
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

@description('Azure region code for naming (e.g., weu, neu, eus)')
@minLength(2)
@maxLength(10)
param regionCode string

@description('Azure region for resource deployment')
param location string = resourceGroup().location


@description('Array of host pool configurations')
param hostPools array

// Example structure:
// [
//   {
//     name: 'main'                    // Suffix for the pool name
//     type: 'Pooled'                  // 'Pooled' or 'Personal'
//     loadBalancerType: 'BreadthFirst' // 'BreadthFirst' or 'DepthFirst'
//     maxSessionLimit: 10             // Max sessions per host (Pooled only)
//     preferredAppGroupType: 'Desktop' // 'Desktop' or 'RailApplications'
//   }
// ]

@description('Array of application group configurations')
param applicationGroups array

// Example structure:
// [
//   {
//     name: 'desktop'                 // Suffix for the app group name
//     type: 'Desktop'                 // 'Desktop' or 'RemoteApp'
//     friendlyName: 'Main Desktop'    // Display name
//     description: 'Desktop access'   // Description
//     hostPoolName: 'main'            // References hostPools[].name
//   }
// ]

@description('Friendly name for the workspace')
param workspaceFriendlyName string

@description('Description for the workspace')
param workspaceDescription string = ''

@description('Tags to apply to all resources')
param tags object = {}

@description('Start VM on Connect (requires Azure AD authentication)')
param startVMOnConnect bool = false

var hostPoolNames = [for pool in hostPools: pool.name]

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-04-03' = [for pool in hostPools: {
  name: '${getResourceAbbreviation('avdHostPool')}-avd-${projectName}-${pool.name}-${environment}-${regionCode}'
  location: location
  tags: tags
  properties: {
    hostPoolType: pool.type
    loadBalancerType: pool.loadBalancerType
    preferredAppGroupType: pool.preferredAppGroupType
    maxSessionLimit: pool.type == 'Pooled' ? pool.maxSessionLimit : null
    startVMOnConnect: startVMOnConnect
    validationEnvironment: false
    personalDesktopAssignmentType: pool.type == 'Personal' ? 'Automatic' : null
  }
}]

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2024-04-03' = [for (appGroup, i) in applicationGroups: {
  name: '${appGroup.type == 'Desktop' ? getResourceAbbreviation('avdDesktopApplicationGroup') : getResourceAbbreviation('avdRemoteAppApplicationGroup')}-avd-${projectName}-${appGroup.name}-${environment}-${regionCode}'
  location: location
  tags: tags
  properties: {
    hostPoolArmPath: hostPool[indexOf(hostPoolNames, appGroup.hostPoolName)].id
    applicationGroupType: appGroup.type
    friendlyName: appGroup.friendlyName
    description: contains(appGroup, 'description') ? appGroup.description : ''
  }
  dependsOn: [
    hostPool
  ]
}]

var workspaceName = '${getResourceAbbreviation('avdWorkspace')}-avd-${projectName}-${environment}-${regionCode}'

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-04-03' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    friendlyName: workspaceFriendlyName
    description: workspaceDescription
    applicationGroupReferences: [for (appGroup, i) in applicationGroups: applicationGroup[i].id]
  }
  dependsOn: [
    applicationGroup
  ]
}

@description('Resource ID of the AVD workspace')
output workspaceId string = workspace.id

@description('Name of the AVD workspace')
output workspaceName string = workspace.name

@description('Array of host pool resource IDs')
output hostPoolIds array = [for (pool, i) in hostPools: hostPool[i].id]

@description('Array of host pool names')
output hostPoolNames array = [for (pool, i) in hostPools: hostPool[i].name]

@description('Array of application group resource IDs')
output applicationGroupIds array = [for (appGroup, i) in applicationGroups: applicationGroup[i].id]

@description('Array of application group names')
output applicationGroupNames array = [for (appGroup, i) in applicationGroups: applicationGroup[i].name]

@description('Example naming convention for resources')
output namingConventionExamples object = {
  workspace: workspaceName
  hostPoolPattern: 'pool-avd-${projectName}-{poolname}-${environment}-${regionCode}'
  desktopAppGroupPattern: 'dag-avd-${projectName}-{groupname}-${environment}-${regionCode}'
  remoteAppGroupPattern: 'rag-avd-${projectName}-{groupname}-${environment}-${regionCode}'
}
