

param accountName string
param serviceName string = 'default'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing  = {
  name: accountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: serviceName
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}



output fileServiceId string = fileService.id
output fileServiceName string = fileService.name
