function Get-SecGroup {
    param(
        [string] $GroupName
    )

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    return Get-MgGroup -Filter "displayName eq '$GroupName'" | Where-Object { $_.GroupTypes -notcontains "Unified" }
}                       

Register-SecGroupCompleter -CommandName Get-SecGroup -ParameterName GroupName