if (-not $Script:SecGroupCache) {
    $script:SecGroupCache = @()
} 

function Update-SecGroupCache {
    $scopes = @("Group.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    $script:SecGroupCache = Get-MgGroup -All | Where-Object { $_.GroupTypes -notcontains "Unified" } 
}
function Use-SecGroup {
    param(
        [string] $GroupName
    )

    if (-not $script:SecGroupCache -or $script:SecGroupCache.Count -eq 0) {
        Update-SecGroupCache
    }   

    if ($script:SecGroupCache -contains $GroupName) {
        Write-Host "[Ok] Group found in cache: $GroupName" -ForegroundColor Green
    } else {
        Write-Host "(!) Group not found in cache" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to attempt to create it? (Y/N)"
        if ($choice -match '^(Y|y)') {
           try {
                $newGroup = New-MgGroup -DisplayName $GroupName -MailEnabled:$false -MailNickname ($GroupName -replace '\s','') -SecurityEnabled:$true
                Write-Host "[Ok] Group created: $($newGroup.Id)" -ForegroundColor Green
                $script:SecGroupCache += $newGroup
           } catch {
                Write-Host "[Error] Failed to create group: $_" -ForegroundColor Red
                return                              
           } 
        }
    }
    Write-Host "You selected Security Group: $GroupName"
    return $script:SecGroupCache | Where-Object { $_.DisplayName -eq $GroupName }
}


Register-ArgumentCompleter -CommandName Use-SecGroup -ParameterName GroupName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $scopes = @("Group.Read.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome

    $groups = if (-not $script:SecGroupCache -or$script:SecGroupCache.Count -eq 0) {
        Update-SecGroupCache
        $script:SecGroupCache
    } else {
        $script:SecGroupCache
    }                               

    $groups | ForEach-Object {
        if ($_.DisplayName -like "$wordToComplete*") {
            [System.Management.Automation.CompletionResult]::new($_.DisplayName, $_.DisplayName, 'ParameterValue', $_.DisplayName)
        }
    }
}                                               