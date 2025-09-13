[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $LocalAdminUser = "BubbleRDP"
)

function AssertAdmin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as an administrator."
    }
}

function Set-HKLM {

    Write-Host "Setting HKLM Keys to propper Values..." -ForegroundColor Yellow


    Write-Host "Enabling Terminal Server" -ForegroundColor Yellow
    Set-ItemProperty `
        -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
        -Name "fDenyTSConnections" `
        -Value 0

    Write-Host "Forcing TLS (High) encryption"
    Set-ItemProperty `
        -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" 
        -Name "SecurityLayer" `
        -Value 2
    Set-ItemProperty `
        -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
        -Name "MinEncryptionLevel" `
        -Value 3

    Write-Host "Allowing for network level Authentication (NLA)"
    Set-ItemProperty `
            -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
            -Name "UserAuthentication" `
            -Value 1
}

function Enable-RdpFirewall {
    Write-Host "Enabling RemoteDesktop on the Firewall"
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

Function Set-LocalAdmin {
    Param(
        [string] $User
    )

    if (-not (Get-LocalUser -Name $User -ErrorAction SilentlyContinue)) {
        $pwd = Read-Host "Enter Password for local remote user '$User'" -AsSecureString
        New-LocalUser `
            -Name $User `
            -Password $pwd `
            -PasswordNeverExpires $true `
            -AccountNeverExpires $true `
            -UserMayNotChangePassword $false `
            -Description "LocalRDP User" | Out-Null

        Add-LocalGroupMember `
            -Group "Remote Desktop User" -Member $User
    }  else {
        Write-Host "Ensure Local user is added to group"
        Add-LocalGroupMember -Group "Remote Desktop User" -Member $User
    }

}

try {
    AssertAdmin

    Set-HKLM
    Enable-RdpFirewall
    Set-LocalAdmin -User $LocalAdminUser

    Write-Host "Finished You should be able to RDP now to this server" -ForegroundColor Yellow

}
catch {
    Write-Error $_.Exception.Message
    throw
}