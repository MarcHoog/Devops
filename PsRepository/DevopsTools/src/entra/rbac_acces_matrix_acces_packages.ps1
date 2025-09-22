[CmdletBinding()]
param(
)


function GetRoleAssignmentMap {
    $roleDefinitionMap = @{}    
    Get-AzRoleDefinition | ForEach-Object {
    $roleDefinitionMap[$_.Id] = $_.Name
}

    return $roleDefinitionMap
}

function Get-DetailedRoleAssignmentsUsers {
    [CmdletBinding()]
    param()

    $roleDefinitionMap = GetRoleAssignmentMap   

    $users = Get-MgUser -All
    $userMap = @{}
    foreach ($u in $users) {
        $userMap[$u.Id] = $u.DisplayName
    }

    $assignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'User' }

    $result = @()
    foreach ($ra in $assignments) {
        $scopeInfo = ConvertFrom-AzScope -Scope $ra.Scope
        $result += [pscustomobject]@{
            Scope              = $ra.Scope
            ScopeType          = $scopeInfo.ScopeType
            RoleDefinition     = $roleDefinitionMap[$ra.RoleDefinitionId]
            PrincipalType      = 'User'
            PrincipalDisplayName = $userMap[$ra.ObjectId] ?? "Unknown"
            SubscriptionId     = $scopeInfo.SubscriptionId
            ResourceGroup      = $scopeInfo.ResourceGroup
            Provider           = $scopeInfo.Provider
            ResourceType       = $scopeInfo.ResourceType
            ResourceName       = $scopeInfo.ResourceName
            SubPath            = $scopeInfo.SubPath
        }
    }

}

function Get-DetailedRoleAssignmentsServicePrincipals {
    [CmdletBinding()]
    param()

    $roleDefinitionMap = GetRoleAssignmentMap  

    $sps = Get-MgServicePrincipal -All
    $spMap = @{}
    foreach ($sp in $sps) {
        $spMap[$sp.Id] = $sp.DisplayName
    }

    $assignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'ServicePrincipal' }

    foreach ($ra in $assignments) {
        $scopeInfo = ConvertFrom-AzScope -Scope $ra.Scope
        [pscustomobject]@{
            Scope              = $ra.Scope
            ScopeType          = $scopeInfo.ScopeType
            RoleDefinition     = $roleDefinitionMap[$ra.RoleDefinitionId]
            PrincipalType      = 'ServicePrincipal'
            PrincipalDisplayName = $spMap[$ra.ObjectId] ?? "Unknown"
            SubscriptionId     = $scopeInfo.SubscriptionId
            ResourceGroup      = $scopeInfo.ResourceGroup
            Provider           = $scopeInfo.Provider
            ResourceType       = $scopeInfo.ResourceType
            ResourceName       = $scopeInfo.ResourceName
            SubPath            = $scopeInfo.SubPath
        }
    }
}

function Get-DetailedRoleAssignmentsGroups {
    [CmdletBinding()]
    param(
        [switch]$IncludeEligibles
    )

    $roleDefinitionMap = GetRoleAssignmentMap           
    
    # Build group map
    $groups = Get-MgGroup -All
    $groupMap = @{}
    foreach ($g in $groups) {
        $groupMap[$g.Id] = $g.DisplayName
    }

    $results = @()

    # ===== ACTIVE ASSIGNMENTS =====
    $assignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'Group' }
    foreach ($ra in $assignments) {
        $scopeInfo = ConvertFrom-AzScope -Scope $ra.Scope
        $results += [pscustomobject]@{
            Scope                = $ra.Scope
            ScopeType            = $scopeInfo.ScopeType
            RoleDefinition       = $roleDefinitionMap[$ra.RoleDefinitionId]
            AssignmentState      = 'Active'
            PrincipalType        = 'Group'
            PrincipalDisplayName = $groupMap[$ra.ObjectId] ?? "Unknown"
            SubscriptionId       = $scopeInfo.SubscriptionId
            ResourceGroup        = $scopeInfo.ResourceGroup
            Provider             = $scopeInfo.Provider
            ResourceType         = $scopeInfo.ResourceType
            Name                 = $scopeInfo.Name
            SubPath              = $scopeInfo.SubPath
        }
    }

    if ($IncludeEligibles) {
        $eligibles = Get-MgRoleManagementResourceRoleEligibilitySchedule -All |
                     Where-Object { $_.PrincipalId -in $groups.Id }

        foreach ($ra in $eligibles) {
            $scopeInfo = ConvertFrom-AzScope -Scope $ra.ScopeId
            $results += [pscustomobject]@{
                Scope                = $ra.ScopeId
                ScopeType            = $scopeInfo.ScopeType
                RoleDefinition       = $roleDefinitionMap[$ra.RoleDefinitionId]
                AssignmentState      = 'Eligible'
                PrincipalType        = 'Group'
                PrincipalDisplayName = $groupMap[$ra.PrincipalId] ?? "Unknown"
                SubscriptionId       = $scopeInfo.SubscriptionId
                ResourceGroup        = $scopeInfo.ResourceGroup
                Provider             = $scopeInfo.Provider
                ResourceType         = $scopeInfo.ResourceType
                Name                 = $scopeInfo.Name
                SubPath              = $scopeInfo.SubPath
            }
        }
    }

    return $results
}


function Get-DetailedRoleAssignmentsServicePrincipals {
    [CmdletBinding()]
    param()

    $roleDefinitionMap = GetRoleAssignmentMap  

    $sps = Get-MgServicePrincipal -All
    $spMap = @{}
    foreach ($sp in $sps) {
        $spMap[$sp.Id] = $sp.DisplayName
    }

    $assignments = Get-AzRoleAssignment | Where-Object { $_.ObjectType -eq 'ServicePrincipal' }

    foreach ($ra in $assignments) {
        $scopeInfo = ConvertFrom-AzScope -Scope $ra.Scope
        [pscustomobject]@{
            Scope              = $ra.Scope
            ScopeType          = $scopeInfo.ScopeType
            RoleDefinition     = $roleDefinitionMap[$ra.RoleDefinitionId]
            PrincipalType      = 'ServicePrincipal'
            PrincipalDisplayName = $spMap[$ra.ObjectId] ?? "Unknown"
            SubscriptionId     = $scopeInfo.SubscriptionId
            ResourceGroup      = $scopeInfo.ResourceGroup
            Provider           = $scopeInfo.Provider
            ResourceType       = $scopeInfo.ResourceType
            ResourceName       = $scopeInfo.ResourceName
            SubPath            = $scopeInfo.SubPath
        }
    }
}

Get-DetailedRoleAssignmentsGroups -IncludeEligibles | Select-Object ScopeType, Name, RoleDefinition, PrincipalType, PrincipalDisplayName | Format-Table -AutoSize   