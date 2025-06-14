param location string = resourceGroup().location
param vnetName string = 'azVnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param vpnGatewaySubnetName string = 'GatewaySubnet'
param vpnGatewaySubnetPrefix string = '10.0.1.0/24'
param vmsSubnetName string = 'VmsSubnet'
param vmsSubnetPrefix string = '10.0.2.0/24'
param PointToSiteGatewayName string = 'PointToSiteGateway'
param PointToSiteGatewayPublicIPName string = 'PointToSiteGatewayPublicIP'
param pointIpAddress string = '202.134.8.0/24'



resource webVnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: vpnGatewaySubnetName
        properties: {
          addressPrefix: vpnGatewaySubnetPrefix
        }
      }
      {
        name: vmsSubnetName
        properties: {
          addressPrefix: vmsSubnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
   
   
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: 'azNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: vpnGatewaySubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-Rdp'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: vpnGatewaySubnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'deny-all'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource PointToSiteGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: PointToSiteGatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
 sku: {
    name: 'Standard'
  }
}

resource PointToSiteGateway 'Microsoft.Network/virtualNetworkGateways@2024-07-01' = {
  name: PointToSiteGatewayName
  location: location
  properties: {
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          subnet: {
            id: webVnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: PointToSiteGatewayPublicIP.id
          }
        }
      }
    ]
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
         '40.0.1.0/24'
        ]
      }
      vpnClientProtocols: [
        
        'OpenVPN'
      ]
      aadAudience: 'c1654b3d-a993-47ad-8a7a-c41ad7cd32ac'
      aadIssuer: 'https://sts.windows.net/1ab3058e-9d34-4c96-8ea3-ccbd34645ada/'
      aadTenant: 'https://login.microsoftonline.com/1ab3058e-9d34-4c96-8ea3-ccbd34645ada/'
    }
  }
}


output vnetId string = webVnet.id
output PointToSiteGatewayId string = PointToSiteGateway.id
output vmSubnetId string = webVnet.properties.subnets[1].id
