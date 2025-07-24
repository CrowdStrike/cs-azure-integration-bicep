targetScope = 'managementGroup'

/*
  This Bicep template assigns the required permissions on Azure management group to enable CrowdStrike
  Indicator of Misconfiguration (IOM)

  Copyright (c) 2024 CrowdStrike, Inc.
*/

@description('Principal Id of the Application Registration in Entra ID.')
param azurePrincipalId string

@description('Type of the Principal. Defaults to ServicePrincipal.')
param azurePrincipalType string = 'ServicePrincipal'

var customRole = {
  roleName: 'cs-website-reader'
  roleDescription: 'CrowdStrike custom role to allow read access to App Service and Function.'
  roleActions: [
    'Microsoft.Web/sites/Read'
    'Microsoft.Web/sites/config/Read'
    'Microsoft.Web/sites/config/list/Action'
    'Microsoft.Web/sites/publish/Action'
  ]
}

var roleDefinitionIds = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
  '21090545-7ca7-4776-b22c-e363652d74d2' // Key Vault Reader
  '7f6c6a51-bcf8-42ba-9220-52d62157d7db' // Azure Kubernetes Service RBAC Reader
]

resource customRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(customRole.roleName, managementGroup().id)
  properties: {
    assignableScopes: [managementGroup().id]
    description: customRole.roleDescription
    permissions: [
      {
        actions: customRole.roleActions
        notActions: []
      }
    ]
    roleName: customRole.roleName
    type: 'CustomRole'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleDefinitionId in roleDefinitionIds: {
    name: guid(azurePrincipalId, roleDefinitionId, managementGroup().id)
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
      principalId: azurePrincipalId
      principalType: azurePrincipalType
    }
  }
]

resource customRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    azurePrincipalId,
    customRoleDefinition.id,
    managementGroup().id
  )
  properties: {
    roleDefinitionId: customRoleDefinition.id
    principalId: azurePrincipalId
    principalType: azurePrincipalType
  }
}
