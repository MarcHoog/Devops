using '../main.bicep'

// =========================================
// Basic AVD Deployment Example
// =========================================
// This example deploys a single pooled host pool
// with a desktop application group and workspace
// =========================================

// Naming parameters
param appName = 'organimmo'
param environment = 'prd'
param regionCode = 'weu'
param location = 'westeurope'

// Workspace configuration
param workspaceFriendlyName = 'Organimmo Production Workspace'
param workspaceDescription = 'Azure Virtual Desktop workspace for Organimmo production environment'

// Host pool configuration
param hostPools = [
  {
    name: 'main'
    type: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 10
    preferredAppGroupType: 'Desktop'
  }
]

// Application group configuration
param applicationGroups = [
  {
    name: 'desktop'
    type: 'Desktop'
    friendlyName: 'Organimmo Desktop'
    description: 'Main desktop environment for Organimmo users'
    hostPoolName: 'main'
  }
]

// Optional: Start VM on Connect
param startVMOnConnect = false

// Tags
param tags = {
  Environment: 'Production'
  Project: 'Organimmo'
  CostCenter: 'IT-Operations'
  Owner: 'IT Team'
  ManagedBy: 'Bicep'
  Workload: 'AVD'
}
