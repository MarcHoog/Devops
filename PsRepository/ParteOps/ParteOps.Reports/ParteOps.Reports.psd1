@{
    GUID = 'f0850977-f88b-4e0a-ad97-a2a29551212e'
    RootModule        = 'ParteOps.Reports.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '7.1'
    Description       = 'Reports submodule for ParteOps'

    FunctionsToExport = @(
        "Export-EntitlementAccessPackageReport"
        "Export-EntitlementAccessPackageRbacReport"
    ) # handled in PSM1
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

