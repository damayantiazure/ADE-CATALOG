
param accountName string
param serviceName string = 'default'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing  = {
  name: accountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: serviceName
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
  }
}

output blobServiceId string = blobService.id
output blobServiceName string = blobService.name
