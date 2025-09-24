function New-SecGroup {
    param(
        [string] $GroupName
    )

    $group = Get-SecGroup -GroupName $GroupName
    if ($group) {
        Write-Host "[Info] Group already exists: $($group.DisplayName) ($($group.Id))" -ForegroundColor DarkGray
        return $group 
    }                                       

    try {
        $scopes = @("Group.ReadWrite.All", "Directory.Read.All", "User.Read.All")
        Connect-MgGraph -Scopes $scopes -NoWelcome
        
        $newGroup = New-MgGroup `
            -DisplayName $GroupName `
            -MailEnabled:$false `
            -MailNickname ($GroupName -replace '\s','') `
            -SecurityEnabled:$true

        Write-Host "[Created] Group: $($newGroup.DisplayName) ($($newGroup.Id))" -ForegroundColor Green

        return $newGroup 
    }
    catch {
        Write-Host "[Error] Failed to create group: $_" -ForegroundColor Red
        return $null
    }
}