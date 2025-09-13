[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$DnsNames,

    [switch] $CreateLocalAdmin,
    [string] $LocalAdminUser = "psremote",

    [switch] $EnableLocalAccountRemoteUACBypass
)

function AssertAdmin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as an administrator."
    }
}

function New-OrGet-HttpsCert {
    param(
        [string] $DnsNames
    )

    Write-Host "Creating self-signed certificate for: $($DnsNames -join ', ')" -ForegroundColor Yellow
    $cert = New-SelfSignedCertificate `
        -DnsName $DnsNames `
        -CertStoreLocation "cert:\LocalMachine\My" `
        -KeyExportPolicy Exportable `
        -KeyLength 2048 `
        -KeyAlgorithm RSA `
        -HashAlgorithm SHA256 `
        -NotAfter (Get-Date).AddYears(5) `
        -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `

    if (-not $cert) {
        throw "Failed to create self-signed certificate."
    }
    return $cert
}

function Ensure-WinRMHTTS