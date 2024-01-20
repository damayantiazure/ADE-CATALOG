
param vnetName string
param location string = resourceGroup().location
param addressPrefix string = '10.2.0.0/16'
param defaultSubnetAddressPrefix string = '10.2.0.0/24'
param backendSubnetAddressPrefix string = '10.2.1.0/24'
param backendSubnetName string = 'backends'
param gatewaySubnetName string = 'gateway'

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: gatewaySubnetName
        type: 'Microsoft.Network/virtualNetworks/subnets'
        properties: {
          addressPrefix: defaultSubnetAddressPrefix
          // networkSecurityGroup: {
          //   id: networkSecurityGroups_mokmjhavnet_default_nsg_westeurope_name_resource.id
          // }
          // applicationGatewayIPConfigurations: [
          //   {
          //     id: '${applicationGateways_moimhaxy124_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
          //   }
          // ]
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }        
      }
      {
        name: backendSubnetName
        type: 'Microsoft.Network/virtualNetworks/subnets'
        properties: {
          addressPrefix: backendSubnetAddressPrefix
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }        
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}


output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetGatewaySubnetId string = vnet.properties.subnets[0].id
output vnetBackendSubnetId string = vnet.properties.subnets[1].id
