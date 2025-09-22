if (-not $Script:AccessPackageCache) {     
    $script:AccessPackageCache = @()
}

function Update-AccessPackageCache {
    $scopes = @("EntitlementManagement.Read.All", "EntitlementManagement.ReadWrite.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    $script:AccessPackageCache = Get-MgIdentityGovernanceEntitlementManagementAccessPackage -All 
}


function Add-SecGroupToAccessPackage {
    [CmdletBinding()]
    param(
        [string] $AccessPackageName,
        [string] $GroupId
    )

    if (-not $script:AccessPackageCache -or $script:AccessPackageCache.Count -eq 0) {
        Update-AccessPackageCache
    }   

    $accessPackage = $script:AccessPackageCache | Where-Object { $_.DisplayName -eq $AccessPackageName }
    if (-not $accessPackage) {
        Write-Host "Access Package not found in cache" -ForegroundColor Red
        return
    } else {
        Write-Host "Access Package found in cache: $AccessPackageName" -ForegroundColor Green
    }

    $existingAssignments = Get-AccessPackageGroupAssignment -PackageId $accessPackage.Id -GroupId $GroupId
    if ($existingAssignments) {
        Write-Host "Group '$GroupId' is already assigned to Access Package '$AccessPackageName'" -ForegroundColor Green
        return
    }
}

Register-ArgumentCompleter -CommandName Add-SecGroupToAccessPackage -ParameterName AccessPackageName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $scopes = @("EntitlementManagement.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $packages = if (-not $script:AccessPackageCache -or $script:AccessPackageCache.Count -eq 0) {
        Update-AccessPackageCache
        $script:AccessPackageCache
    } else {
        $script:AccessPackageCache
    }                               

    $packages | ForEach-Object {
        if ($_.DisplayName -like "$wordToComplete*") {
            [System.Management.Automation.CompletionResult]::new($_.DisplayName, $_.DisplayName, 'ParameterValue', $_.DisplayName)
        }
    }
}                                       