@description('Environment name (dev, tst, prd)')
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environment string

@description('Project or application name')
param projectName string

@description('Cost center for billing')
param costCenter string

@description('Owner or team responsible for the resource')
param owner string

@description('Additional custom tags')
param customTags object = {}

@description('Created Date')
param createdDate string = utcNow('yyyy-MM-dd')

// Generate standard tags
var standardTags = {
  Environment: environment
  Project: projectName
  ManagedBy: 'Bicep'
  CreatedDate: createdDate
  CostCenter: costCenter
  Owner: owner
}


var allTags = union(standardTags, customTags)

@description('Combined tags object')
output tags object = allTags
