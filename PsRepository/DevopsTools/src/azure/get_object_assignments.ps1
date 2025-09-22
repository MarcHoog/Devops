function Get-ObjectAssignment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ObjectId
    )

    $results = @()

    $context = Get-AzContext -ErrorAction SilentlyContinue
    if ($null -ne $context) {
        if (-not $SkipTenantCheck) {
            Write-Host "Current Azure context:" -ForegroundColor Cyan
            Write-Host "  Account : $($context.Account.Id)"
            Write-Host "  Tenant  : $($context.Tenant.Id)"

            $choice = Read-Host "Use this context? (Y/N)"
            if ($choice -notin @('Y','y')) {
                Connect-AzAccount -ErrorAction Stop | Out-Null
                $context = Get-AzContext
            }
        }
    }
    else {
        Connect-AzAccount -ErrorAction Stop | Out-Null
        $context = Get-AzContext
    }

    $subscriptions = Get-AzSubscription -TenantId $context.Tenant.Id    
    foreach ($sub in $subscriptions) {
        Write-Host "Checking subscription: $($sub.Name) [$($sub.Id)]" -ForegroundColor Cyan
        Set-AzContext -SubscriptionId $sub.Id -TenantId $sub.TenantId | Out-Null
        $activeAssignments = Get-AzRoleAssignment -ObjectId $ObjectId -ErrorAction SilentlyContinue

        foreach ($a in $activeAssignments) {
            $results += [pscustomobject]@{
                Subscription   = $sub.Name
                SubscriptionId = $sub.Id
                AssignmentType = "Active"
                Role           = $a.RoleDefinitionName
                Scope          = $a.Scope
                ObjectId       = $a.ObjectId
                PrincipalType  = $a.ObjectType
            }
        }

        try {
            $eligibleAssignments = Get-AzRoleEligibilityScheduleInstance -Scope "/subscriptions/$($sub.Id)" `
                -ErrorAction SilentlyContinue | Where-Object { $_.PrincipalId -eq $ObjectId }

            foreach ($e in $eligibleAssignments) {
                $results += [pscustomobject]@{
                    Subscription   = $sub.Name
                    SubscriptionId = $sub.Id
                    AssignmentType = "Eligible"
                    Role           = $e.RoleDefinitionDisplayName
                    Scope          = $e.Scope
                    ObjectId       = $e.PrincipalId
                    PrincipalType  = $e.PrincipalType
                }
            }
        } catch {
            Write-Warning "Could not fetch eligible assignments for $($sub.Name) – you might need Az.Resources >= 6.0.0 and PIM access"
        }
    }

    return $results
}
