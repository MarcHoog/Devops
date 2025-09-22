
function ConvertFrom-AzScope {
    <#
    .SYNOPSIS
    Parses an Azure resource scope string into a structured object.

    .DESCRIPTION
    Azure resource IDs (scopes) follow a predictable pattern starting at 
    subscription, management group, or directory root level. This function 
    extracts key components into a PSCustomObject.

    .PARAMETER Scope
    The Azure resource scope string to parse.

    .OUTPUTS
    PSCustomObject with properties:
        - ScopeType     : DirectoryRoot | ManagementGroup | Subscription | ResourceGroup | Resource
        - SubscriptionId: Subscription GUID (if applicable)
        - ManagementGroup: Management group ID (if applicable)
        - ResourceGroup : Resource group name (if applicable)
        - Provider      : Resource provider (if applicable)
        - ResourceType  : Type of the top-level resource (if applicable)
        - ResourceName  : Name of the top-level resource (if applicable)
        - SubPath       : Any nested resource path beyond ResourceName
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    # Normalize and split into segments
    $parts = ($Scope.Trim('/') -split '/') | Where-Object { $_ -ne '' }

    $obj = [ordered]@{
        ScopeType       = $null
        SubscriptionId  = $null
        ManagementGroup = $null
        ResourceGroup   = $null
        Provider        = $null
        ResourceType    = $null
        ResourceName    = $null
        SubPath         = $null
    }

    if ($parts.Length -eq 0) {
        $obj.ScopeType = 'DirectoryRoot'
    }
    elseif ($parts[0] -eq 'providers' -and $parts[1] -eq 'Microsoft.Management' -and $parts[2] -eq 'managementGroups') {
        $obj.ScopeType       = 'ManagementGroup'
        $obj.Name = $parts[3]
    }
    elseif ($parts[0] -eq 'subscriptions') {
        $obj.ScopeType      = 'Subscription'
        $obj.Name = $parts[1]

        if ($parts.Length -ge 4 -and $parts[2] -eq 'resourceGroups') {
            $obj.ScopeType     = 'ResourceGroup'
            $obj.Name = $parts[3]

            if ($parts.Length -ge 6 -and $parts[4] -eq 'providers') {
                $obj.ScopeType     = 'Resource'
                $obj.Provider      = $parts[5]
                $obj.ResourceType  = $parts[6]
                $obj.Name  = $parts[7]
                if ($parts.Length -gt 8) {
                    $obj.SubPath = '/' + ($parts[8..($parts.Length-1)] -join '/')
                }
            }
        }
        elseif ($parts.Length -ge 4 -and $parts[2] -eq 'providers') {
            $obj.ScopeType     = 'Resource'
            $obj.Provider      = $parts[3]
            $obj.ResourceType  = $parts[4]
            $obj.Name  = $parts[5]
            if ($parts.Length -gt 6) {
                $obj.SubPath = '/' + ($parts[6..($parts.Length-1)] -join '/')
            }
        }
    }
    else {
        throw "Unsupported scope format: $Scope"
    }

    return [pscustomobject]$obj
}