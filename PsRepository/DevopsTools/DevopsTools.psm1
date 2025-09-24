# Import all scripts in the module

# IIS scripts
#. $PSScriptRoot/src/iis/iis_copy_site.ps1
#. $PSScriptRoot/src/iis/iis_paste_site.ps1
#. $PSScriptRoot/src/iis/iis_wacs_quick_cert.ps1
#. $PSScriptRoot/src/iis/install_iis_role.ps1

. $PSScriptRoot/src/utils/select_from_menu.ps1
. $PSScriptRoot/src/utils/show_todo_list.ps1


# Entra  Scripts
. $PSScriptRoot/src/entra/auto-completers/groups.ps1
. $PSScriptRoot/src/entra/auto-completers/users.ps1 
. $PSScriptRoot/src/entra/get_access_package_entitlement.ps1
. $PSScriptRoot/src/entra/get_access_package_group_assignments.ps1
. $PSScriptRoot/src/entra/functions/users.ps1
. $PSScriptRoot/src/entra/functions/groups.ps1
. $PSScriptRoot/src/entra/functions/access_package.ps1          
. $PSScriptRoot/src/entra/functions/catalog.ps1
. $PSScriptRoot/src/entra/reports/show_azure_access_package_group_matrix.ps1    
. $PSScriptRoot/src/entra/reports/show_access_package_group_resource_matrix.ps1                                                     
# Azure scripts 
. $PSScriptRoot/src/azure/set_azworkspace.ps1
. $PSScriptRoot/src/azure/get_object_assignments.ps1
. $PSScriptRoot/src/azure/functions/convert_az_scope.ps1    
#. $PSscriptRoot/src/azure/show_azcontextpretty.ps1
#. $PSscriptRoot/src/azure/entra/convert_az_scope.ps1
#. $PSscriptRoot/src//entra/entra_access_matrix.ps1
#. $PSscriptRoot/src/azure/entra/rbac_acces_matrix_acces_packages.ps1