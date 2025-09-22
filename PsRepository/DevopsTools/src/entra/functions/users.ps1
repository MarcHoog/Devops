
function Get-UserId {
    [CmdletBinding()]
    param(
        [string] $UserPrincipalName
    )

    if (-not $script:UserCache -or $script:UserCache.Count -eq 0) {
        Update-UserCache
    }   

    $user = $script:UserCache | Where-Object { $_.UserPrincipalName -eq $UserPrincipalName }
    if (-not $user) {
        Write-Host "User not found in cache: $UserPrincipalName" -ForegroundColor Red
        return $null
    } else {
        Write-Host "User found in cache: $($user.DisplayName) ($($user.Id))" -ForegroundColor Green
        return $user.Id
    }
}               

Register-UserCompleter -CommandName Get-UserId -ParameterName UserPrincipalName                                                              
