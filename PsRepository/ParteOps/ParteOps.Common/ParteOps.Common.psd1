@{
    GUID = '50410d07-18b9-4163-8b8b-f6cbdf4810be'
    RootModule        = 'ParteOps.Common.psm1'
    ModuleVersion     = '0.1.0'
    Author            = 'Your Name'
    CompanyName       = 'Your Org'
    PowerShellVersion = '7.1'
    Description       = 'Common submodule for ParteOps'

    FunctionsToExport = @(
        "Format-TodoList",
        "Select-FromMenu"
    ) 
    CmdletsToExport   = @()
    AliasesToExport   = @()
}

