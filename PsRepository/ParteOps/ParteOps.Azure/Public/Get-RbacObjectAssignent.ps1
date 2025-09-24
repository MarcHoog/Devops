function Get-RbacObjectAssignment {
    [CmdletBinding()]
    param(
        [string]$ObjectId,
        [string[]]$SubscriptionId,
        [switch]$SkipTenantCheck = $false
    )
    
    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    
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

    if ($SubscriptionId) {
        $subsToCheck = @()
        foreach ($subId in $SubscriptionId) {
            $sub = Get-AzSubscription -SubscriptionId $subId -ErrorAction SilentlyContinue
            if ($null -ne $sub) {
                $subsToCheck += $sub
            }
            else {
                Write-Warning "Subscription with ID $subId not found or you don't have access"
            }
        }
    }
    else {
        $subsToCheck = @()
        $subsToCheck += Get-AzSubscription -TenantId $context.Tenant.Id
    }
    
    foreach ($sub in $subsToCheck) {
        Write-Host "Checking subscription: $($sub.Name) [$($sub.Id)]" -ForegroundColor Cyan
        Set-AzContext -SubscriptionId $sub.Id -TenantId $sub.TenantId | Out-Null
        if (-not $ObjectId) {
            $activeAssignments = Get-AzRoleAssignment  -ErrorAction SilentlyContinue    
            Write-Host "Fetching assignments for all objects" -ForegroundColor Yellow
        }
        else {
            $activeAssignments = Get-AzRoleAssignment -ObjectId $ObjectId -ErrorAction SilentlyContinue
            Write-Host "Fetching assignments for object: $ObjectId" -ForegroundColor Yellow
        }


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
