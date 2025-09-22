function Get-AzureAccessPackageMatrixReport {                   

    [cmdletbinding()]
    param(
        [string] $CatalogId
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")    
    $catalog =  Get-MgEntitlementManagementCatalog -All | Where-Object { $_.Id -eq $CatalogId }










}