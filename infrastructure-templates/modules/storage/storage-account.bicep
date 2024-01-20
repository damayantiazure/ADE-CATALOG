

param accountName string
param uamiName string
param location string = resourceGroup().location
param skuName string = 'Standard_RAGRS'
param kind string = 'StorageV2'
param dnsEndpointType string = 'Standard'
param publicNetworkAccess string = 'Disabled'
param defaultToOAuthAuthentication bool = false
param accessTier string = 'Hot'


// Built In roles
// Owner: "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
// Contributor: "b24988ac-6180-42a0-ab88-20f7382dd24c"
var CONTRIBUTOR_ROLE_DEFINITION_ID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: accountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    dnsEndpointType: dnsEndpointType
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    publicNetworkAccess: publicNetworkAccess
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: accessTier
  }
}



resource storageContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('Contributor', storageAccount.name)
  scope: storageAccount
  properties: {
    principalId: uami.properties.principalId
    roleDefinitionId: CONTRIBUTOR_ROLE_DEFINITION_ID
  }
}

module staticWebsite 'static-website/static-website.bicep' = {
  name: 'static-website-${storageAccount.name}'
  params: {
    location: location    
    storageAccountName: storageAccount.name
    userAssignedIdentityName: uami.name
  }
  dependsOn: [   
    storageContributorRoleAssignment
  ]
}

module blobService 'blob-service.bicep' = {
  name: 'blob-service'
  params: {
    accountName: storageAccount.name
  }
}

module fileService 'file-service.bicep' = {
  name: 'file-service'
  params: {
    accountName: storageAccount.name
  }
}
/*
module webContainer 'container.bicep' = {
  name: 'container'
  params: {
    accountName: storageAccount.name
  }
}*/

output id string = storageAccount.id
output name string = storageAccount.name
output properties object = storageAccount.properties
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
output primaryLocation string = storageAccount.location


