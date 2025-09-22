function Get-SecGroup {
    param(
        [string] $GroupName
    )

    if (-not $script:SecGroupCache -or $script:SecGroupCache.Count -eq 0) {
        Update-SecGroupCache
    }

    return $script:SecGroupCache | Where-Object { $_.DisplayName -eq $GroupName } | Select-Object Id
}

function New-SecGroup {
    param(
        [string] $GroupName
    )

    try {
        $newGroup = New-MgGroup `
            -DisplayName $GroupName `
            -MailEnabled:$false `
            -MailNickname ($GroupName -replace '\s','') `
            -SecurityEnabled:$true

        Write-Host "[Created] Group: $($newGroup.DisplayName) ($($newGroup.Id))" -ForegroundColor Green

        $script:SecGroupCache += $newGroup
        return $newGroup | Select-Object Id
    }
    catch {
        Write-Host "[Error] Failed to create group: $_" -ForegroundColor Red
        return $null
    }
}

function GetOrCreate-SecGroup {
    param(
        [string] $GroupName
    )

    $group = Get-SecGroup -GroupName $GroupName

    if ($group) {
        Write-Host "[Ok] Found group in cache: $($group.DisplayName)" -ForegroundColor Green
        return $group
    }
    else {
        Write-Host "(!) Group not found: $GroupName" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to create it? (Y/N)"
        if ($choice -match '^(Y|y)') {
            return New-SecGroup -GroupName $GroupName 
        }
        else {
            Write-Host "[Skipped] Group not created." -ForegroundColor DarkGray
            return $null
        }
    }
}

Register-GroupCompleter -CommandName GetOrCreate-SecGroup -ParameterName GroupName
Register-GroupCompleter -CommandName Get-SecGroup -ParameterName GroupName              
Register-GroupCompleter -CommandName New-SecGroup -ParameterName GroupName  