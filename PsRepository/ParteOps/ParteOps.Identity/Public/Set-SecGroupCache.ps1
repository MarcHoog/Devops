function Set-SecGroupCache {
    $scopes = @("Group.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    $script:SecGroupCache = Get-MgGroup -All | Where-Object { $_.GroupTypes -notcontains "Unified" }
}