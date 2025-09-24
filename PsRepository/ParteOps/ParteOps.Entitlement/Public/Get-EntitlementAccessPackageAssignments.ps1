function Get-EntitlementAccessPackageAssignments {
    [CmdletBinding()]
    param(
        [string]$State,
        [string]$UserId,
        [string]$PackageId  
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    if ($State) {
        $State = $State.ToLower()
        if ($State -notin @("delivered", "pending", "denied", "revoked", "expired")) {
            throw "Invalid state '$State'. Valid states are: delivered, pending, denied, revoked, expired."
        }
    }

    $results = @()

    $assignments = Get-MgEntitlementManagementAssignment -ExpandProperty target, accessPackage

    foreach ($assignment in $assignments) {

        $result = [pscustomobject]@{
            PackageName = $assignment.AccessPackage.DisplayName
            PackageId   = $assignment.AccessPackage.Id
            State       = $assignment.State
            UserId      = $assignment.Target.Id
            UserDisplayName = $assignment.Target.DisplayName    
            UserEmail  = $assignment.Target.Email
        }
        if ($UserId -and $assignment.Target.Id -ne $UserId) {
            continue
        } elseif ($PackageId -and $assignment.AccessPackage.Id -ne $PackageId  ) {
            continue
        } elseif ($State -and $assignment.State -ne $State) {
            continue
        } else {
            $results += $result
        }       
    }
    return $results
}