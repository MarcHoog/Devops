function Get-GroupPackageMembershipReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GroupIds
    )

    $requiredModules = @("Microsoft.Graph.Groups", "Microsoft.Entra")
    $scopes          = @("Group.Read.All", "Directory.Read.All", "User.Read.All")

    # Check modules before connecting
    $notInstalled = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
    if ($notInstalled) {
        Write-Host "Missing required modules: $($notInstalled -join ', ')" -ForegroundColor Red
        Write-Host "Install them with: Install-Module $($notInstalled -join ', ')" -ForegroundColor Yellow
        return
    }

    # Connect once
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
    try {
        Connect-MgGraph -Scopes $scopes -NoWelcome -ErrorAction Stop
    } catch {
        Write-Host "Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
        return
    }

    # Load lookup data
    $entitlements          = Get-EntitlementAssignments -State "Delivered"
    $catalogPackageGroups  = Get-CatalogPackageGroups

    # Cache group display names
    $groupNames = @{}
    Get-MgGroup -All | ForEach-Object {
        $groupNames[$_.Id] = $_.DisplayName
    }

    $report = @()

    foreach ($groupId in $GroupIds) {
        Write-Host "Processing group: $($groupNames[$groupId] ?? $groupId)" -ForegroundColor Cyan

        # Get members of this group
        $groupMembers = Get-MgGroupMember -GroupId $groupId -All

        foreach ($member in $groupMembers) {
            # Fetch user info only when needed
            $user = $null
            if ($member.AdditionalProperties["userPrincipalName"]) {
                $user = [pscustomobject]@{
                    Id              = $member.Id
                    DisplayName     = $member.AdditionalProperties["displayName"]
                    UserPrincipal   = $member.AdditionalProperties["userPrincipalName"]
                }
            }
            else {
                try {
                    $mgUser = Get-MgUser -UserId $member.Id -ErrorAction Stop
                    $user   = [pscustomobject]@{
                        Id            = $mgUser.Id
                        DisplayName   = $mgUser.DisplayName
                        UserPrincipal = $mgUser.UserPrincipalName
                    }
                } catch {
                    $user = [pscustomobject]@{
                        Id            = $member.Id
                        DisplayName   = "Unknown"
                        UserPrincipal = "Unknown"
                    }
                }
            }

            # Find matching assignments
            $userAssignments   = $entitlements | Where-Object { $_.UserId -eq $user.Id }
            $groupAssignments  = $catalogPackageGroups | Where-Object { $_.GroupId -eq $groupId }

            $matches = foreach ($ua in $userAssignments) {
                foreach ($ga in $groupAssignments) {
                    if ($ua.PackageId -eq $ga.PackageId) {
                        [pscustomobject]@{
                            GroupId         = $groupId
                            GroupName       = $groupNames[$groupId] ?? "Unknown"
                            UserId          = $user.Id
                            UserName        = $user.DisplayName
                            UserPrincipal   = $user.UserPrincipal
                            PackageName     = $ua.PackageName
                            PackageId       = $ua.PackageId
                            LinkedByPackage = "Yes"
                        }
                    }
                }
            }

            if ($matches) {
                $report += $matches
            } else {
                $report += [pscustomobject]@{
                    GroupId         = $groupId
                    GroupName       = $groupNames[$groupId] ?? "Unknown"
                    UserId          = $user.Id
                    UserName        = $user.DisplayName
                    UserPrincipal   = $user.UserPrincipal
                    PackageName     = $null
                    PackageId       = $null
                    LinkedByPackage = "No"
                }
            }
        }
    }

    return $report
}
