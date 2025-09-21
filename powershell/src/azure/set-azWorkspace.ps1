function Connect-AzTenantSubscription {
    <#
    .SYNOPSIS
    Interactively connect to an Azure tenant + subscription, with optional PIM role activation.

    .DESCRIPTION
    Lets you choose a tenant from a predefined list, pick a subscription, and optionally 
    activate an eligible PIM role in that subscription.

    .PARAMETER Pim
    If provided, lists your eligible roles and prompts to activate one.

    .EXAMPLE
    Connect-AzTenantSubscription
    Connect to tenant + subscription only.

    .EXAMPLE
    Connect-AzTenantSubscription -Pim
    Connect and then activate a PIM role.
    #>

    [CmdletBinding()]
    param(
        [switch]$Pim
    )

    # Hardcode your tenants
    $tenants = @{
        "Work Tenant" = "11111111-1111-1111-1111-111111111111"
        "Lab Tenant"  = "22222222-2222-2222-2222-222222222222"
        "Personal tenant" = "33333333-3333-3333-3333-333333333333"
    }

    function Select-FromMenu($title, $options) {
        Write-Host "`n$title" -ForegroundColor Cyan
        for ($i = 0; $i -lt $options.Count; $i++) {
            Write-Host "[$i] $($options[$i])"
        }
        do {
            $choice = Read-Host "Choose 0-$($options.Count-1)"
        } until ($choice -match '^\d+$' -and [int]$choice -lt $options.Count)
        return $options[$choice]
    }

    # --- Tenant Selection ---
    $tenantName = Select-FromMenu "Select a Tenant:" ($tenants.Keys)
    $tenantId   = $tenants[$tenantName]

    Connect-AzAccount -Tenant $tenantId | Out-Null

    # --- Subscription Selection ---
    $subs = Get-AzSubscription | Sort-Object Name
    if (-not $subs) { Write-Host "No subscriptions in tenant."; return }

    $subChoice = Select-FromMenu "Select a Subscription:" ($subs.Name)
    $sub       = $subs | Where-Object { $_.Name -eq $subChoice }
    Set-AzContext -SubscriptionId $sub.Id -TenantId $tenantId | Out-Null

    Write-Host "`nConnected to $tenantName ($tenantId) / $($sub.Name) ($($sub.Id))" -ForegroundColor Green

    # --- Optional PIM Activation ---
    if ($Pim) {
        # Needs Az.Resources >= 6.x
        $roles = Get-AzRoleEligibilityScheduleInstance -Scope "/subscriptions/$($sub.Id)" `
            | Select-Object RoleDefinitionDisplayName, RoleDefinitionId, Id

        if (-not $roles) {
            Write-Host "No eligible PIM roles found." -ForegroundColor Yellow
            return
        }

        $roleNames = $roles.RoleDefinitionDisplayName
        $roleChoice = Select-FromMenu "Select a PIM Role to Activate:" $roleNames
        $role = $roles | Where-Object { $_.RoleDefinitionDisplayName -eq $roleChoice }

        $params = @{
            Scope            = "/subscriptions/$($sub.Id)"
            RoleDefinitionId = $role.RoleDefinitionId
            Justification    = "Activation via Connect-AzTenantSubscription"
            DurationInHours  = 1
        }

        Start-AzRoleAssignmentScheduleRequest @params | Out-Null
        Write-Host "`nRequested activation for PIM role: $roleChoice" -ForegroundColor Green
    }
}
