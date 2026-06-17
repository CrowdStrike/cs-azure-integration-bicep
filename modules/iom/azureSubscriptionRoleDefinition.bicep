targetScope = 'subscription'

/*
  This Bicep template defines the required permissions at Azure Subscription scope to enable CrowdStrike
  Indicator of Misconfiguration (IOM)
  Copyright (c) 2024 CrowdStrike, Inc.
*/

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

var resourceLockRole = {
  roleName: 'Resource Lock Administrator'
  roleDescription: 'Can Administer Resource Locks.'
  roleActions: [
    'Microsoft.Authorization/locks/*'
  ]
}

resource customRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(customRole.roleName, tenant().tenantId)
  properties: {
    assignableScopes: [subscription().id]
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

resource resourceLockRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(resourceLockRole.roleName, tenant().tenantId)
  properties: {
    assignableScopes: [subscription().id]
    description: resourceLockRole.roleDescription
    permissions: [
      {
        actions: resourceLockRole.roleActions
        notActions: []
      }
    ]
    roleName: resourceLockRole.roleName
    type: 'CustomRole'
  }
}

output customRoleDefinitionId string = customRoleDefinition.id
output resourceLockRoleDefinitionId string = resourceLockRoleDefinition.id
