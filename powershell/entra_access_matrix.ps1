[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$GroupIds
)

$modules = @("Microsoft.Graph.Groups", "Microsoft.Entra")
$scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")

$NotInstalled = @()
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        $NotInstalled += $module
    } 
}

if ($NotInstalled.Count -gt 0) {
    Write-Host "The following required modules are not installed: $($NotInstalled -join ', ')" -ForegroundColor Red
    Write-Host "Please install them using Install-Module and try again." -ForegroundColor Red
    exit
}

$ErrorActionPreference = "Stop"

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan                 
Connect-MgGraph -Scopes $scopes -NoWelcome

If (-not (Get-MgContext)) {
    Write-Host "Failed to connect to Microsoft Graph. Please ensure you have the necessary permissions." -ForegroundColor Red
    exit
}

function Get-CatalogPackageGroups {
    [CmdletBinding()]
    param()

    $results = @()

    $catalogs = Get-MgEntitlementManagementCatalog -All

    foreach ($catalog in $catalogs) {
        $packages = Get-MgEntitlementManagementAccessPackage -ExpandProperty catalog -All |
            Where-Object { $_.Catalog.Id -eq $catalog.Id } |
            Select-Object Id, DisplayName

        foreach ($package in $packages) {
            $roleScopes = Get-MgEntitlementManagementAccessPackage -AccessPackageId $package.Id -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"
            foreach ($rs in $roleScopes.ResourceRoleScopes) {
                if ($rs.Scope -and $rs.scope.OriginSystem -eq "AadGroup") {
                    $results += [pscustomobject]@{
                        CatalogName   = $catalog.DisplayName
                        CatalogId     = $catalog.Id
                        PackageName   = $package.DisplayName
                        PackageId     = $package.Id
                        GroupId       = $rs.scope.OriginId
                    }
                }
            }
        }   
    }

    return $results
}

function Get-EntitlementAssignments {
    [CmdletBinding()]
    param(
        [string]$State
    )

    $results = @()

    $assignments = Get-MgEntitlementManagementAssignment -ExpandProperty target, accessPackage

    foreach ($assignment in $assignments) {
        if ($State -and $assignment.State -ne $State) {
            continue
        }
        $results += [pscustomobject]@{
            PackageName = $assignment.AccessPackage.DisplayName
            PackageId   = $assignment.AccessPackage.Id
            UserId      = $assignment.Target.Id
            UserDisplayName = $assignment.Target.DisplayName    
            UserEmail  = $assignment.Target.Email
        }
    }
    return $results
}

$entitlements = Get-EntitlementAssignments -State "Delivered"
$groupNames = @{}
Get-MgGroup -All | ForEach-Object {
    $groupNames[$_.Id] = $_.DisplayName
} 
$userInfo = @{}
Get-MgUser -All | ForEach-Object {
    $userInfo[$_.Id] = @{DisplayName = $_.DisplayName; UserPrincipalName = $_.UserPrincipalName}                        
}       

$report = @()
$catalogPackageGroups = Get-CatalogPackageGroups                 
foreach ($group in $groupIds) {
    $AssignedGroupUsers = Get-MgGroupMember -GroupId $group -All
    foreach ($user in $AssignedGroupUsers) {
        if (-not $userInfo.ContainsKey($user.Id)) {
            $userInfo[$user.Id] = @{DisplayName = "Unknown"; UserPrincipalName = "Unknown"}
        }
        $userAssignments = $entitlements | Where-Object { $_.UserId -eq $user.Id }
        $groupAssignments = $catalogPackageGroups | Where-Object { $_.GroupId -eq $group }
        $matchingAssignments = foreach ($ua in $userAssignments) {
            foreach ($ga in $groupAssignments) {
                if ($ua.PackageId -eq $ga.PackageId) {
                    [pscustomobject]@{
                        GroupId       = $group
                        GroupName     = $groupNames[$group]
                        UserId        = $user.Id
                        UserName      = $userInfo[$user.Id].DisplayName
                        UserPrincipal = $userInfo[$user.Id].UserPrincipalName
                        PackageName   = $ua.PackageName
                        PackageId     = $ua.PackageId
                        LinkedByPackage = "Yes"
                    }
                }
            }
        }

        if ($matchingAssignments) {
            $report += $matchingAssignments
        } else {
            $report += [pscustomobject]@{
                GroupId         = $group
                GroupName       = $groupNames[$group]
                UserId          = $user.Id
                UserName        = $userInfo[$user.Id].DisplayName
                UserPrincipal   = $userInfo[$user.Id].UserPrincipalName
                PackageName     = $null
                PackageId       = $null
                LinkedByPackage = "No"
            }
        }
    }
}

return $report 

