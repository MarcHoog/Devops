@{
    GUID = 'b808485b-b56e-454c-bcac-14751710d7bc'
    RootModule        = 'ParteOps.Rbac.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '7.1'
    Description       = 'Rbac submodule for ParteOps'

    FunctionsToExport = @(
        "ConvertFrom-AzScope"
        "Get-RbacObjectAssignment"
    ) 
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

