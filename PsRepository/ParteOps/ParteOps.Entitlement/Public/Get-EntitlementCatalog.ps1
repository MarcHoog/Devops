function Get-EntitlementCatalog {
    param (
        [string[]]$CatalogId,
        [string[]]$ExpandProperties
    )
    
    $scopes = @("Group.Read.All", "Directory.Read.All", "EntitlementManagement.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $catalogs = Get-mgEntitlementManagementCatalog -All 
    if ($ExpandProperties) {
        $expandString = $ExpandProperties -join ","
        $catalogs = Get-mgEntitlementManagementCatalog -All -ExpandProperty $expandString
    } else {
        $catalogs = Get-mgEntitlementManagementCatalog -All
    }                               

    if ($CatalogId) {
        $catalogs = $catalogs | Where-Object { $CatalogId -contains $_.Id }
    }

    return $catalogs            
    }     