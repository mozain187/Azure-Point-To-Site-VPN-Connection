param adminPassword string

module vnet 'vnet.bicep' = {
  name: 'vnet'
  params: {
    
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    vmSubnetId: vnet.outputs.vmSubnetId
    adminPassword: adminPassword
  }
}

