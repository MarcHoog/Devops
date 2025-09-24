function Get-SecGroupFromCache {
    param(
        [string] $GroupName
    )

    if (-not $script:SecGroupCache -or $script:SecGroupCache.Count -eq 0) {
        Update-SecGroupCache
    }

    return $script:SecGroupCache | Where-Object { $_.DisplayName -eq $GroupName }
}

Register-SecGroupCompleter -CommandName Get-SecGroupFromCache -ParameterName GroupName
