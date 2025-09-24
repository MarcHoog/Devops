function Export-EntitlementAccessPackageRbacReport {
    [CmdletBinding()]
    param(
        [string[]] $CatalogId,
        [string[]] $PackageId,
        [string[]] $SubscriptionId,
        [string]   $ObjectId,

        [switch]   $SkipTenantCheck,
        [switch]   $ExportToExcel,
        [string]   $OutputPath = ".\AccessPackageRbacMatrix.xlsx"
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $groupCache = @{}
    foreach ($g in Get-MgGroup -All) {
        $groupCache[$g.Id] = $g.DisplayName
    }
    $collectionResources = @()
    $collectionResources = Get-EntitlementCatalogResources -CatalogId $CatalogId |
        Where-Object { $_.OriginSystem -eq "AadGroup" }
    if ($ObjectId) {
        $collectionResources = $collectionResources | Where-Object { $_.OriginId -eq $ObjectId }
    }

    $packagesResources = @()
    $packagesResources = Get-EntitlementAccessPackageResources -CatalogId $CatalogId -PackageId $PackageId |
        Where-Object { $_.OriginSystem -eq "AadGroup" }
    
    $packageList = $packagesResources | Select-Object -Property PackageId, PackageName -Unique

    $rbacAssignments = @()
    $rbacAssignments = Get-RbacObjectAssignment -SubscriptionId $SubscriptionId -SkipTenantCheck:$SkipTenantCheck
    
    $results = @()

    foreach ($resource in $collectionResources) {
        $groupId   = $resource.OriginId
        $groupAssignments = $rbacAssignments | Where-Object { $_.ObjectId -eq $groupId }

        foreach ($a in $groupAssignments) {
            $parsed = ConvertFrom-AzScope -Scope $a.Scope
            $row = [ordered]@{
                ResourceScope = $a.Scope
                ResourceName  = $parsed.Name
                ResourceType  = $parsed.ResourceType
                GroupId       = $groupId
                GroupName     = $groupCache[$groupId]
                RoleName      = $a.Role
                JIT           = if ($a.AssignmentType -eq "Eligible") { "✔" } else { "" }
            }

            foreach ($pkg in $packageList) {
                $hasIt = $packagesResources | Where-Object {
                    $_.OriginId -eq $groupId -and $_.PackageId -eq $pkg.PackageId
                }
                $row[$pkg.PackageName] = if ($hasIt) { "✔" } else { "" }
            }

            $results += [pscustomobject]$row
        }
    }

    if ($ExportToExcel) {
        if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
            Write-Error "The ImportExcel module is required. Install it with: Install-Module ImportExcel -Scope CurrentUser"
            return
        }

        $results | Export-Excel -Path $OutputPath `
            -WorksheetName "RBACMatrix" `
            -TableName "AccessPackageRbacMatrix" `
            -AutoSize -TableStyle Medium2

        Write-Host "Excel table exported to $OutputPath" -ForegroundColor Green
    }
    else {
        return $results
    }
}
