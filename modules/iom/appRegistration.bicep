targetScope = 'subscription'
extension microsoftGraphV1

var applicationName = 'CrowdStrikeCSPM-${uniqueString(subscription().subscriptionId)}'
var applicationDescription = 'CrowdStrike Falcon CSPM'
var redirectUris = ['https://falcon.crowdstrike.com/cloud-security/registration/app/cspm/cspm_accounts']

resource microsoftGraphServicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  appId: '00000003-0000-0000-c000-000000000000'
}

var applicationPermissions = [
  { name: 'Application.Read.All', id: '9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30', type: 'Role' }
  { name: 'Application.ReadWrite.OwnedBy', id: '18a4783c-866b-4cc7-a460-3d5e5662c884', type: 'Role' }
  { name: 'AuditLog.Read.All', id: 'b0afded3-3588-46d8-8b3d-9842eff778da', type: 'Role' }
  { name: 'DeviceManagementRBAC.Read.All', id: '49f0cc30-024c-4dfd-ab3e-82e137ee5431', type: 'Scope' }
  { name: 'Directory.Read.All', id: '7ab1d382-f21e-4acd-a863-ba3e13f7da61', type: 'Role' }
  { name: 'Group.Read.All', id: '5b567255-7703-4780-807c-7be8301ae99b', type: 'Role' }
  { name: 'Policy.Read.All', id: '246dd0d5-5bd0-4def-940b-0421030a5b68', type: 'Role' }
  { name: 'Reports.Read.All', id: '230c1aed-a721-4c5d-9cb4-a90514e508ef', type: 'Role' }
  { name: 'RoleManagement.Read.Directory', id: '483bed4a-2ad3-4361-a73b-c83ccdbdc53c', type: 'Role' }
  { name: 'User.Read.All', id: 'df021288-bdef-4463-88db-98f22de89214', type: 'Role' }
  { name: 'User.ReadBasic.All', id: 'b340eb25-3456-403f-be2f-af7a0d370277', type: 'Scope' }
  { name: 'UserAuthenticationMethod.Read.All', id: 'aec28ec7-4d02-4e8c-b864-50163aea77eb', type: 'Scope' }
]

/* Create Application Registration in Entra Id */
resource application 'Microsoft.Graph/applications@v1.0' = {
  description: applicationDescription
  displayName: applicationName
  // passwordCredentials: []
  requiredResourceAccess: [
    {
      resourceAccess: [for permission in applicationPermissions: { id: permission.id, type: permission.type }]
      resourceAppId: microsoftGraphServicePrincipal.appId
    }
  ]
  uniqueName: applicationName
  web: {
    redirectUris: [for uri in redirectUris: '${uri}']
  }
}

/* Create Service Principal for Application Registration */
resource servicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: application.appId
}

/* Grant consent to Application permissions */
resource applicationPermissionGrant 'Microsoft.Graph/appRoleAssignedTo@v1.0' = [
  for permission in applicationPermissions: if (permission.type == 'Role') {
    principalId: servicePrincipal.id
    resourceId: microsoftGraphServicePrincipal.id
    appRoleId: permission.id
  }
]

/* Grant consent to Delegated permissions */
resource delegatedPermissionGrant 'Microsoft.Graph/oauth2PermissionGrants@v1.0' = {
  clientId: servicePrincipal.id
  consentType: 'AllPrincipals'
  resourceId: microsoftGraphServicePrincipal.id
  scope: join(
    map(filter(applicationPermissions, permissions => permissions.type == 'Scope'), permission => permission.name),
    ' '
  )
}

output applicationId string = application.appId
output principalId string = application.id
