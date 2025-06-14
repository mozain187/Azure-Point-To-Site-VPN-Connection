param location string = resourceGroup().location
param adminPassword string
param vmSubnetId string
param storageSuffix string = 'core.windows.net'
param vnetName string = 'azVnet'


resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
name: toLower('${vnetName}storage')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    blobServices: {
      deleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }
    

  }
}


resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: 'azNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id:vmSubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        
        }
      }
    ]
   
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'azVm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'azVm'
      adminUsername: 'azureuser'
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${storageAccount.name}.blob.${storageSuffix}'
      }
    }
  }
}
