# Import all scripts in the module

# IIS scripts
#. $PSScriptRoot/src/iis/iis_copy_site.ps1
#. $PSScriptRoot/src/iis/iis_paste_site.ps1
#. $PSScriptRoot/src/iis/iis_wacs_quick_cert.ps1
#. $PSScriptRoot/src/iis/install_iis_role.ps1

. $PSScriptRoot/src/helpers/select_from_menu.ps1

# Entra  Scripts
. $PSScriptRoot/src/entra/get_access_package_entitlement.ps1
. $PSScriptRoot/src/entra/get_access_package_group_assignments.ps1
. $PSScriptRoot/src/entra/cli_helper.ps1

# Azure scripts 
. $PSScriptRoot/src/azure/set_azworkspace.ps1
. $PSScriptRoot/src/azure/get_object_assignments.ps1
#. $PSscriptRoot/src/azure/show_azcontextpretty.ps1
#. $PSscriptRoot/src/azure/entra/convert_az_scope.ps1
#. $PSscriptRoot/src//entra/entra_access_matrix.ps1
#. $PSscriptRoot/src/azure/entra/rbac_acces_matrix_acces_packages.ps1