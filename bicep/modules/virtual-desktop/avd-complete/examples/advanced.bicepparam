using '../main.bicep'

// =========================================
// Advanced AVD Deployment Example
// =========================================
// This example deploys multiple host pools with
// both Desktop and RemoteApp application groups
// =========================================

// Naming parameters
param appName = 'enterprise'
param environment = 'prd'
param regionCode = 'weu'
param location = 'westeurope'

// Workspace configuration
param workspaceFriendlyName = 'Enterprise Production Workspace'
param workspaceDescription = 'Complete AVD environment with desktop and application streaming'

// Multiple host pools for different use cases
param hostPools = [
  // Desktop pool for full desktop experience
  {
    name: 'desktop'
    type: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 10
    preferredAppGroupType: 'Desktop'
  }
  // Application pool for published apps
  {
    name: 'apps'
    type: 'Pooled'
    loadBalancerType: 'DepthFirst'
    maxSessionLimit: 20
    preferredAppGroupType: 'RailApplications'
  }
  // Personal desktops for executives
  {
    name: 'executive'
    type: 'Personal'
    loadBalancerType: 'Persistent'
    maxSessionLimit: 1
    preferredAppGroupType: 'Desktop'
  }
]

// Multiple application groups
param applicationGroups = [
  // Desktop application group
  {
    name: 'desktop'
    type: 'Desktop'
    friendlyName: 'Full Desktop'
    description: 'Complete Windows desktop environment'
    hostPoolName: 'desktop'
  }
  // RemoteApp groups for different departments
  {
    name: 'office'
    type: 'RemoteApp'
    friendlyName: 'Office Applications'
    description: 'Microsoft Office suite and productivity tools'
    hostPoolName: 'apps'
  }
  {
    name: 'finance'
    type: 'RemoteApp'
    friendlyName: 'Finance Applications'
    description: 'Finance-specific applications and tools'
    hostPoolName: 'apps'
  }
  {
    name: 'engineering'
    type: 'RemoteApp'
    friendlyName: 'Engineering Tools'
    description: 'CAD and engineering applications'
    hostPoolName: 'apps'
  }
  // Executive desktop
  {
    name: 'exec-desktop'
    type: 'Desktop'
    friendlyName: 'Executive Desktop'
    description: 'Personal desktop for executive team'
    hostPoolName: 'executive'
  }
]

// Enable Start VM on Connect for cost optimization
param startVMOnConnect = true

// Comprehensive tags
param tags = {
  Environment: 'Production'
  Project: 'Enterprise-AVD'
  CostCenter: 'IT-Operations'
  Owner: 'Cloud Team'
  ManagedBy: 'Bicep'
  Workload: 'AVD'
  BusinessUnit: 'Corporate'
  Criticality: 'High'
}
