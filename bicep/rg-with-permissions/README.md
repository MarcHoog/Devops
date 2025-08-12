# Resource Group with Permissions

This Bicep module deploys a resource group and assigns a Reader role to a specified group.

## Deleting Deployed Resources

To delete the resource group (and all resources within it), use:

```sh
az group delete --name <your-resource-group-name>
```

To delete only the deployment record (not the resources):

```sh
az deployment sub delete --name <deployment-name>
```

Replace `<your-resource-group-name>` and `<deployment-name>` with your actual values.