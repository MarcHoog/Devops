@{
    GUID = 'd2a0ff40-6c2c-49e5-bf9a-d6ab50377c4e'
    RootModule        = 'ParteOps.IIs.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '4.0'
    Description       = 'Iis submodule for ParteOps'

    FunctionsToExport = @(
        "Get-IisSites",
        "Get-IisSitePortalVar",
        "Get-IisSitePool",
        "Set-IisSites",
        "Set-SitePortaalConfig"


    ) # handled in PSM1
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

