@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_A8m_v2'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string

param nicName string = 'myVMNic'
param storageAccountName string
param diskOsName string
param disk0Name string 
param disk1Name string

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' existing = {
  name: nicName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource diskOs 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: diskOsName
}

resource disk0 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: disk0Name
}

resource disk1 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: disk1Name
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  tags: {
    Practice: 'D365'
    Description: 'Business Central on prem to SaaS sync'
    Owner: 'Joerg Rau'
    CreatedOnUTC: 'Unknown'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'standard'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'Standard_LRS'
          id: diskOs.id
        }
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
            id: disk0.id
          }
          toBeDetached: false
        }
        {
          lun: 1
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
            id: disk1.id
          }
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
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
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}
