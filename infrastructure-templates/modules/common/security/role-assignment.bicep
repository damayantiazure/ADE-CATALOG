

param principalId string
param roleDefinitionId string

// Built In roles
// "Owner": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
// "Contributor": "b24988ac-6180-42a0-ab88-20f7382dd24c"

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('RoleAssignment', principalId)  
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
  }
}
