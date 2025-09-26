param prefix string
param location string = resourceGroup().location

resource hostpool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' = {
  name: 'vdPool-${prefix}'
  location: location
  properties: {
    friendlyName: 'vdPool-${prefix}'
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    maxSessionLimit: 10
    preferredAppGroupType: 'Desktop'
  }
}



output id string = hostpool.id
