if (-not $script:UserCache) {     
    $script:UserCache = @()
}
function Update-UserCache {
    $scopes = @("User.Read.All", "Directory.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    $script:UserCache = Get-MgUser -All |
       Select-Object DisplayName, Id, UserPrincipalName 
}           

function Register-UserCompleter {
    Register-ArgumentCompleter -CommandName Get-UserId -ParameterName UserPrincipalName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $scopes = @("User.Read.All", "Directory.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $users = if (-not $script:UserCache -or $script:UserCache.Count -eq 0) {
        Update-UserCache
        $script:UserCache
    } else {
        $script:UserCache
    }                               

    $users | ForEach-Object {
        if ($_.UserPrincipalName -like "$wordToComplete*") {
            [System.Management.Automation.CompletionResult]::new($_.UserPrincipalName, $_.UserPrincipalName, 'ParameterValue', $_.DisplayName)
        }
    }
}       
}