function Set-AzWorkspace {
    <#
    .SYNOPSIS
    Interactively connect to an Azure tenant + subscription, with optional PIM role activation.

    .DESCRIPTION
    Lets you choose a tenant from a predefined list, pick a subscription, and optionally 
    activate an eligible PIM role in that subscription.

    .PARAMETER Pim
    If provided, lists your eligible roles and prompts to activate one.

    .EXAMPLE
    set-azWorkspace
    Connect to tenant + subscription only.

    #>

    [CmdletBinding()]
    param(
        [switch]$Pim
    )

    $tenants = @{
        "Parte" = "11e0eb60-cd4f-4cfa-8b51-399ef21ab565"
        "Fellowship" = "94061f62-1f05-4fbb-8b40-e14dedd8c029"
    }

    $tenantResult = Select-FromMenu -Title "Select a Tenant:" -Options $tenants
    $tenantId   = $tenantResult.Value
    $tenantName = $tenantResult.Name

    Connect-AzAccount -Tenant $tenantId  | Out-Null
    Write-Host "Connected to tenant: $tenantName ($tenantId)" -ForegroundColor Green                        

    Show-AzContextPretty

    <#
    if ($Pim) {
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
    #>
}
