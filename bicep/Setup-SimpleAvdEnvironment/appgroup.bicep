param prefix string
param location string
param hostPoolId string
param appGroups array

resource appgroup 'Microsoft.DesktopVirtualization/applicationGroups@2023-09-05' = [for ag in appGroups: {
  name: 'vdag-${prefix}-${ag.name}'
  location: location
  properties: {
    friendlyName: ag.friendlyName
    description: ag.description
    applicationGroupType: ag.type
    hostPoolArmPath: hostPoolId
  }
}]

// ✅ Fix: Index into the resource collection
output appGroupIds array = [for (ag, i) in appGroups: appgroup[i].id]
