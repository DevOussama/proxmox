## Add a New Storage with Snippets Content Type

1. Go to **Datacenter** in the Proxmox GUI.
2. Select **Storage** in the left menu.
3. Click **local** then add **snippet**.

## To apply in Proxmox, run the following command:
```sh
terraform apply -var-file="environments\\prod.tfvars" -auto-approve
```
