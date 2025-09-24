@{
    GUID = 'd976ab69-7061-4602-8aaa-8b180b9963ac'
    RootModule        = 'ParteOps.Groups.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '7.1'
    Description       = 'Entitlement submodule for ParteOps'

    FunctionsToExport = @(
        "Get-SecGroup"
        "Get-SecGroupFromCache"
        "Copy-SecGroup"
        "Set-SecGroupCache"
        "New-SecGroup"
    ) # handled in PSM1
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

