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

