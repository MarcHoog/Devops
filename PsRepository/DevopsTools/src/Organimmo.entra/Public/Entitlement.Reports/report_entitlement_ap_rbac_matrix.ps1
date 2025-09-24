function Get-AzureAccessPackageRbacReport {
    [CmdletBinding()]
    param(
        [string[]] $CatalogId,
        [string[]] $PackageId,
        [string[]] $SubscriptionId,
        [string]   $ObjectId,

        [switch]   $SkipTenantCheck,
        [switch]   $ExportToExcel,
        [string]   $OutputPath = ".\AccessPackageRbacMatrix.xlsx",
        [switch]   $Cache                           
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    if (-not $script:GroupCache -or -not $Cache) {
        $script:GroupCache = @{}
        foreach ($g in Get-MgGroup -All) {
            $script:GroupCache[$g.Id] = $g.DisplayName
        }
    }
    $groupCache = $script:GroupCache

    if (-not $script:CollectionResources -or -not $Cache) {
        $script:CollectionResources = Get-CatalogResources -CatalogId $CatalogId |
            Where-Object { $_.OriginSystem -eq "AadGroup" }
    }
    $collectionResources = $script:CollectionResources
    if ($ObjectId) {
        $collectionResources = $collectionResources | Where-Object { $_.OriginId -eq $ObjectId }
    }

    if (-not $script:PackageResources -or -not $Cache) {
        $script:PackageResources = Get-AccessPackageResources -CatalogId $CatalogId -PackageId $PackageId |
            Where-Object { $_.OriginSystem -eq "AadGroup" }
    }
    $packagesResources = $script:PackageResources
    $packageList = $packagesResources | Select-Object -Property PackageId, PackageName -Unique

    if (-not $script:RbacAssignments -or -not $Cache) {
        $script:RbacAssignments = Get-RbacAssignment -SubscriptionId $SubscriptionId -SkipTenantCheck:$SkipTenantCheck 
    }
    $rbacAssignments = $script:RbacAssignments
    $results = @()

    foreach ($resource in $collectionResources) {
        $groupId   = $resource.OriginId
        # This are all the Assignments for this group from RB
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
