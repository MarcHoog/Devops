param prefix string
param location string
param applicationGroupReferences array


resource workspace 'Microsoft.DesktopVirtualization/workspaces@2023-09-05' = {
  name: 'vdws-${prefix}'
  location: location
  properties: {
    description: 'AVD POC Workspace'
    friendlyName: 'vdws-${prefix}'
    applicationGroupReferences: applicationGroupReferences
  }
}

output id string = workspace.id
