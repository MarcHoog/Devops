@{
    GUID = '86f473e4-3d6f-4d70-b66a-7d0b1ec3b73e'
    RootModule        = 'ParteOps.Entitlement.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '7.1'
    Description       = 'Entitlement submodule for ParteOps'

    FunctionsToExport = @(
        "Get-EntitlementAccessPackage"
        "Get-EntitlementAccessPackageAssignments"
        "Get-EntitlementAccessPackageResources"
        "Get-EntitlementCatalog"
        "Get-EntitlementCatalogResources"
    ) 
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

