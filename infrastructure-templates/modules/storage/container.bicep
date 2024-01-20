

param accountName string
param blobServiceName string = 'default'
param containerName string = '$web'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing  = {
  name: accountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: blobServiceName
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: containerName
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

output containerId string = container.id

