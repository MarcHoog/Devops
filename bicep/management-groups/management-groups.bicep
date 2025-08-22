targetScope = 'tenant'

@description('New org root MG under Tenant Root Group (or another MG)')
param companyRootId string = 'shroomish'
param companyRootDisplayName string = 'Shroomish'
param parentMgId string = ''

@description('Child mg under company root')
param childCompanyRootMgs array = [
  {
    id: 'dev-test'
    displayName: 'Dev Test'
  }
  {
    id: 'prd'
    displayName: 'Production'
  }
  {
    id: 'exam-ref'
    displayName: 'Exam Reference'
  }
]

@description('Children under exam-ref (optional)')
param examRefChildren array = [
  { id: 'az104', displayName: 'Az104' }
]


resource companyRoot 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: companyRootId
  properties: {
    displayName: companyRootDisplayName
    details: empty(parentMgId) ? null : {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', parentMgId)
      }
    }
  }
}


resource children 'Microsoft.Management/managementGroups@2023-04-01' = [ for mg in childCompanyRootMgs: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: companyRoot.id
      }
    }
  }
}]


resource examRefGrandChildren 'Microsoft.Management/managementGroups@2023-04-01' = [ for mg in examRefChildren: {
  name: mg.id
  properties: {
    displayName: mg.displayName
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', 'exam-ref')
      }
    }
  }
}]
