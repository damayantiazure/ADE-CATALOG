
param subnetId string
param endpointName string
param storageAccountName string
param storageServiceGroupName string
param dnsZoneId string
param location string = resourceGroup().location


var networkIterfaceCardName = '${endpointName}-nic'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = {
  name: endpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: networkIterfaceCardName
    privateLinkServiceConnections: [
      {
        name: endpointName        
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            storageServiceGroupName
          ]
        }
      }
    ]
  }
}


resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-${storageServiceGroupName}-core-windows-net'
        properties: {
          privateDnsZoneId: dnsZoneId
        }
      }
    ]
  }
}
