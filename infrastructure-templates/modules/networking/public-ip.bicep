
param publicIpAddressName string
param location string = resourceGroup().location
param skuName string = 'Standard'
param skuTier string = 'Regional'
param publicIPAllocationMethod string = 'Static'


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {  
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: publicIPAllocationMethod
    idleTimeoutInMinutes: 4
    ipTags: [ ]
  }
}


output publicIPAddressName string = publicIPAddress.name
output publicIPAddressId string = publicIPAddress.id
output publicIPAddress string = publicIPAddress.properties.ipAddress
