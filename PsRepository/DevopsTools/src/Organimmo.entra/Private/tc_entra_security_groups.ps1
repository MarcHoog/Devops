if (-not $Script:SecGroupCache) {
    $script:SecGroupCache = @()
} 

function Update-SecGroupCache {
    $scopes = @("Group.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "User.Read.All")
    Connect-MgGraph -Scopes $scopes -NoWelcome
    $script:SecGroupCache = Get-MgGroup -All | Where-Object { $_.GroupTypes -notcontains "Unified" } 
}

function Register-GroupCompleter {
    param(
        [string]$CommandName,
        [string]$ParameterName = "GroupName"
    )

    Register-ArgumentCompleter -CommandName $CommandName -ParameterName $ParameterName -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete)

        if (-not $script:SecGroupCache -or $script:SecGroupCache.Count -eq 0) {
            Update-SecGroupCache
        }

        $script:SecGroupCache |
            Where-Object { $_.DisplayName -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new(
                    $_.DisplayName,
                    $_.DisplayName,
                    'ParameterValue',
                    "Group: $($_.DisplayName)"
                )
            }
    }
}