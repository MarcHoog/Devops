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
