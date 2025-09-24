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
        $prdGroupsTransiantMembers = Get-PrdGroupMemberships
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
            foreach ($prdGroup in $prdGroupsTransiantMembers) {
                $inPrdGroup = $prdGroup.MemberOfIds -contains $resource.OriginId
                $row[$prdGroup.GroupName] = if ($inPrdGroup) { "✔" } else { "" }
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
