function Get-PrdGroupMemberships {
    <#
    .SYNOPSIS
        Get transitive group memberships for predefined PRD groups.

    .DESCRIPTION
        For each hardcoded PRD group, retrieves all groups it is a member of
        using Microsoft Graph `Get-MgGroupTransitiveMemberOf`.

    .OUTPUTS
        PSCustomObject with GroupName and MemberOfIds.
    #>

    [CmdletBinding()]
    param()

    # Define PRD groups
    $PrdGroups = @{
        "4c3b6cf3-5384-4ac5-9a88-130c85e7f5bb" = "Pluto Ops PRD"
        "54905ba4-c8df-405e-bd47-1f2e94b03f73" = "Pluto Support PRD"
        "a245f62f-1eb7-42e0-834d-c0b4a983a273" = "Pluto Developer PRD"
    }

    $results = foreach ($g in $PrdGroups.GetEnumerator()) {
        $memberOf = Get-MgGroupTransitiveMemberOf -GroupId $g.Key -All
        [pscustomobject]@{
            GroupName   = $g.Value
            GroupId     = $g.Key
            MemberOfIds = $memberOf | Select-Object -ExpandProperty Id
        }
    }

    return $results
}
