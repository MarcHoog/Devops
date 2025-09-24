function Get-AccessPackageResources {
    [CmdletBinding()]
    param(
        [string] $CatalogId,
        [string] $PackageId
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $groupNames = @{}
    foreach ($g in Get-MgGroup -All) {
        $groupNames[$g.Id] = $g.DisplayName
    }                           
    $results = @()
    $catalogs = if ($CatalogId) {
        Get-MgEntitlementManagementCatalog -All | Where-Object { $_.Id -eq $CatalogId }
    } else {
        Get-MgEntitlementManagementCatalog -All
    }

    foreach ($catalog in $catalogs) {

        # Get packages for this catalog, filter if PackageId is specified
        $packages = Get-MgEntitlementManagementAccessPackage -ExpandProperty catalog -All |
            Where-Object { $_.Catalog.Id -eq $catalog.Id -and (-not $PackageId -or $_.Id -eq $PackageId) } |
            Select-Object Id, DisplayName

        foreach ($package in $packages) {
            $roleScopes = Get-MgEntitlementManagementAccessPackage `
                -AccessPackageId $package.Id `
                -ExpandProperty "resourceRoleScopes(`$expand=role,scope)"

            foreach ($rs in $roleScopes.ResourceRoleScopes) {
                    $results += [pscustomobject]@{
                        CatalogName  = $catalog.DisplayName
                        CatalogId   = $catalog.Id
                        PackageName = $package.DisplayName      
                        PackageId   = $package.Id
                        OriginId    = $rs.Scope.OriginId
                        OriginSystem = $rs.Scope.OriginSystem
                }
            }
        }
    }

    return $results
}
