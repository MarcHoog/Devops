function Get-AzureAccessPackageReport {
    [CmdletBinding()]
    param(
        [string[]] $CatalogId,
        [string[]] $PackageId,
        [switch]  $IncludeMemberOf,
        [string]   $OutputPath = ".\AccessPackageMatrix.xlsx",
        [switch]   $ExportToExcel
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    if ($IncludeMemberOf) {
        
        $PrdGroups = @{
            "4c3b6cf3-5384-4ac5-9a88-130c85e7f5bb" = "Pluto Ops PRD"
            "54905ba4-c8df-405e-bd47-1f2e94b03f73" = "Pluto Support PRD"
            "a245f62f-1eb7-42e0-834d-c0b4a983a273" = "Pluto Developer PRD"
        }

        $prdGroupsTransiantMembers = @{}
        foreach ($g in $PrdGroups.GetEnumerator()) {
            $memberOf = Get-MgGroupTransitiveMemberOf -GroupId $g.Key -All
            $prdGroupsTransiantMembers[$g.Value] = $memberOf | Select-Object Id -ExpandProperty Id
        }
    }

    $groupCache = @{}
    foreach ($g in Get-MgGroup -All) {
        $groupCache[$g.Id] = $g.DisplayName
    }

    # Get resources and package memberships
    $collectionResources = Get-CatalogResources -CatalogId $CatalogId | Where-Object { $_.OriginSystem -eq "AadGroup" }
    $packages = Get-AccessPackageResources -CatalogId $CatalogId -PackageId $PackageId | Where-Object { $_.OriginSystem -eq "AadGroup" }
    $packageList = $packages | Select-Object -Property PackageId, PackageName, CatalogId, CatalogName -Unique | Sort-Object CatalogName, PackageName        

    $results = @()

    foreach ($resource in $collectionResources) {
        $row = [ordered]@{
            CatalogName = $resource.CatalogName
            GroupId     = $resource.OriginId
            GroupName   = $groupCache[$resource.OriginId]
        }

        foreach ($pkg in $packageList) {
            $hasIt = $packages | Where-Object {
                $_.OriginId -eq $resource.OriginId -and $_.PackageId -eq $pkg.PackageId
            }
            $row[$pkg.PackageName] = if ($hasIt) { "✔" } else { "" }
        }

        if ($IncludeMemberOf) {
            foreach ($prdGroup in $PrdGroups.GetEnumerator()) {
                $inPrdGroup = $prdGroupsTransiantMembers[$prdGroup.Value] -contains $resource.OriginId
                $row[$prdGroup.Value] = if ($inPrdGroup) { "✔" } else { "" }
            } 
        }  

        $results += [pscustomobject]$row
    }

    if ($ExportToExcel) {
        if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
            Write-Error "The ImportExcel module is required. Install it with: Install-Module ImportExcel -Scope CurrentUser"
            return
        }

        $results | Export-Excel -Path $OutputPath `
            -WorksheetName "Matrix" `
            -TableName "AccessPackageMatrix" `
            -AutoSize `
            -TableStyle Medium6

        Write-Host "Excel table exported to $OutputPath" -ForegroundColor Green
    }
    return $results
}
