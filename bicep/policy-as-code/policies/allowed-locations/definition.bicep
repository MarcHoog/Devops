targetScope = 'managementGroup'

@description('Stable name. Do not rename after creation.')
param policyName string = 'allowed-locations-custom'

@description('Display name and category shown in Azure Policy.')
param displayName string = 'Allowed locations (Custom)'
param category string = 'General'
param mode string = 'All'

var rules      = json(loadTextContent('policy.rules.json'))
var parameters = json(loadTextContent('policy.parameters.json'))

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    displayName: displayName
    mode: mode
    metadata: {
      category: category
      version: '1.0.0'   // bump when rules change
    }
    parameters: parameters
    policyRule: rules
  }
}

output policyDefinitionId string = policyDef.id
