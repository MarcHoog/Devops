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

Register-GroupCompleter -CommandName New-SecGroup -ParameterName GroupName  
