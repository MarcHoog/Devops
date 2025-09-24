function  Get-EntitlementCatalogResources {
    param (
        [string[]]$CatalogId
    )

    $catalogs = Get-EntitlementCatalog -CatalogId $CatalogId -ExpandProperties @("resources")

    $results = @()  
    foreach ($catalog in $catalogs) {
        foreach ($resource in $catalog.Resources) {
            $results += [pscustomobject]@{
                CatalogId       = $catalog.Id
                CatalogName     = $catalog.DisplayName  
                OriginId        = $resource.originId
                OriginSystem    = $resource.originSystem
            }
        }                   

    }

    return $results

}