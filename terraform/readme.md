# Proxmox Terraform Quick Guide

## Storage Configuration
1. Install Proxmox VE 8.2-2 ISO (this guide is tested with this version)
2. Navigate to **Datacenter** in Proxmox GUI
3. Select **Storage** from left menu
4. Click **local** and add **snippet** content type

## Terraform Deployment
```sh
terraform apply -var-file="environments/prod.tfvars" -auto-approve
```

## Prerequisites
1. Configure SSL certificate for secure Proxmox communication
2. Define Proxmox endpoint in `prod.tfvars`:
    ```
    proxmox_api_url = "https://yourproxmoxurl:8006/api2/json"
    ```
3. Configure network settings in `prod.tfvars`

4. Configure all VMs CPU, disk space, RAM, etc.. in `prod.tfvars`  

## DNS Resolution Troubleshooting
If experiencing DNS issues, follow these steps:

1. Check current DNS configuration:
    ```sh
    cat /etc/resolv.conf
    ```

2. Add Google DNS servers:
    ```sh
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    ```

3. Verify DNS resolution:
    ```sh
    nslookup google.com
    ```

### Persistent DNS Configuration
Edit `/etc/systemd/resolved.conf`:
```ini
[Resolve]
DNS=8.8.8.8 8.8.4.4
```

Apply changes:
```sh
systemctl restart systemd-resolved
```