function Get-AccessPackage {
    [CmdletBinding()]
    param(
        [string[]] $CatalogId,
        [string[]] $PackageId,
        [string[]] $ExpandProperties = @()
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $result = @()
    if ($CatalogId) {
        if (-not ('Catalog' -in $ExpandProperties)) {               
            $ExpandProperties += 'Catalog'
        }
        $result = Get-MgEntitlementManagementAccessPackage -All -ExpandProperty ($ExpandProperties -join ",") |
            Where-Object { $_.Catalog -and $CatalogId -contains $_.Catalog.Id }         
    }
    else {
        $result = Get-MgEntitlementManagementAccessPackage -All -ExpandProperty ($ExpandProperties -join ",")
    }

    return $result | Where-Object { -not $PackageId -or $_.Id -in $PackageId }
}

function Get-AccessPackageResources {
    [CmdletBinding()]
    param(
        [string[]] $CatalogId,
        [string[]] $PackageId,
        [switch] $IncludeGroupMembership
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $results = @()
    $packages = Get-AccessPackage -CatalogId $CatalogId -PackageId $PackageId -ExpandProperties @("Catalog")

    foreach ($package in $packages) {
        $roleScopes = Get-MgEntitlementManagementAccessPackage `
            -AccessPackageId $package.Id `
            -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"

        foreach ($rs in $roleScopes.ResourceRoleScopes) {
            $results += [pscustomobject]@{
                CatalogName   = $package.Catalog.DisplayName
                CatalogId     = $package.Catalog.Id
                PackageName   = $package.DisplayName
                PackageId     = $package.Id
                OriginId      = $rs.Scope.OriginId
                OriginSystem  = $rs.Scope.OriginSystem
            }
        }
    }

    return $results
    }
