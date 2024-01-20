
param dnsZoneName string
param vnetName string
param vnetId string

var linkName = 'link-${dnsZoneName}-${vnetName}'

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
}
 
resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnszone
  name: linkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}


output dnsZoneId string = dnszone.id
