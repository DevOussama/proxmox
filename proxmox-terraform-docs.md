# Proxmox Infrastructure with Terraform Documentation
## Infrastructure Overview & Network Architecture

### Network Configuration Overview
```
Router IP: 192.168.0.1
Subnet: 192.168.0.0/24 (255.255.255.0)
DHCP Range: 192.168.0.100 - 192.168.0.199
Static IPs:
- Proxmox Node: 192.168.0.102 (node1)
- Proxmox Node: 192.168.0.103 (node2)
- Master Node VM: 192.168.0.200
- Worker Node VM: 192.168.0.201
```

### Router Configuration Details
#### Basic Network Settings
- Router IP Address: 192.168.0.1
- Subnet Mask: 255.255.255.0
- DNS Relay: Enabled
- Local Domain Name: [Configurable]

#### DHCP Server Configuration
- DHCP Server: Enabled
- IP Range: 192.168.0.100 to 192.168.0.199
- Lease Time: 1440 minutes (24 hours)
- Gateway: 192.168.0.1 (Router IP)
- DNS Server: 192.168.0.1 (Router IP)

## Infrastructure Components

### 1. Proxmox Provider Configuration
```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.0.102:8006/api2/json"
  username = "root@pam"
  password = "Ets240790"
}
```
**Important Security Note**: Consider using environment variables or a vault for credentials in production.

### 2. Cloud-Init Configurations

#### Master Node Cloud-Init
```yaml
Hostname: master_node
IP Address: 192.168.0.200/24
Gateway: 192.168.0.1
DNS: 192.168.0.1
Packages:
- qemu-guest-agent
- openssh-server
User: ubuntu
Access: sudo with passwordless access
```

#### Worker Node Cloud-Init
```yaml
Hostname: worker_node
IP Address: 192.168.0.201/24
Gateway: 192.168.0.1
DNS: 192.168.0.1
Packages:
- qemu-guest-agent
- openssh-server
User: ubuntu
Access: sudo with passwordless access
```

### 3. Virtual Machine Specifications

#### Master Node VM (microk8s-master-node)
```hcl
VM ID: 4320
Resources:
- CPU: 2 cores (x86-64-v2-AES)
- Memory: 2048MB dedicated + 2048MB floating
- Storage: 32GB on local-lvm
Network:
- Bridge: vmbr0
- Model: virtio
Startup Order: 1 (First to start)
```

#### Worker Node VM (microk8s-worker-node-1)
```hcl
VM ID: 4322
Resources:
- CPU: 2 cores (x86-64-v2-AES)
- Memory: 2048MB dedicated + 2048MB floating
- Storage: 32GB on local-lvm
Network:
- Bridge: vmbr0
- Model: virtio
Startup Order: 2 (Starts after master)
```

## MicroK8s Configuration

### Master Node Setup
```bash
Automated installations:
- MicroK8s (version 1.31)
- DNS addon
- Dashboard addon
Configuration:
- User added to microk8s group
- Kubeconfig generated and stored
```

### Worker Node Setup
```bash
Automated installations:
- MicroK8s (version 1.31)
- DNS addon
- Dashboard addon
Configuration:
- User added to microk8s group
- Kubeconfig generated and stored
```

## Network Flow & Communication

### Internal Network Communication
1. **VM to VM Communication**
   - Direct communication through vmbr0 bridge
   - Static IP assignment ensures consistent addressing
   - Full mesh connectivity between nodes

2. **VM to Host Communication**
   - Through vmbr0 bridge
   - QEMU guest agent enabled for enhanced integration

3. **External Communication**
   - All traffic routes through 192.168.0.1
   - NAT handled by router for internet access

## Security Considerations

### Network Security
1. **IP Assignment**
   - Static IPs outside DHCP range prevents conflicts
   - Predictable addressing for infrastructure components

2. **Access Control**
   - SSH key-based authentication
   - Passwordless sudo for ubuntu user
   - No root password login

### Service Security
1. **Proxmox**
   - Access via HTTPS (8006)
   - PAM authentication
   - Root access required for API

2. **MicroK8s**
   - Default secure configuration
   - Addons enabled: dns, dashboard
   - Configuration stored in /home/ubuntu/.kube/config

## Deployment Instructions

### Prerequisites
1. **Network Requirements**
   - Router configured as documented
   - Static IPs available and not in DHCP range
   - Network connectivity between Proxmox nodes

2. **Proxmox Requirements**
   - Proxmox VE installed and configured
   - API access enabled
   - Storage configured (local-lvm)

### Deployment Steps
1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Validate Configuration**
   ```bash
   terraform plan
   ```

3. **Apply Configuration**
   ```bash
   terraform apply
   ```

4. **Verify Deployment**
   ```bash
   # Check VM status
   qm list

   # Verify network connectivity
   ping 192.168.0.200
   ping 192.168.0.201

   # Check MicroK8s status (from master node)
   ssh ubuntu@192.168.0.200 'microk8s status'
   ```

## Maintenance & Troubleshooting

### Common Issues & Solutions

1. **Network Connectivity Issues**
   ```bash
   # Check network interface
   ip addr show

   # Verify routing
   ip route show

   # Test connectivity
   ping 192.168.0.1
   ```

2. **VM Startup Issues**
   ```bash
   # Check VM status
   qm status <vmid>

   # View logs
   tail /var/log/proxmox/qemu-server/<vmid>.log
   ```

3. **MicroK8s Issues**
   ```bash
   # Check status
   microk8s status

   # Inspect services
   microk8s kubectl get pods -A
   ```

### Backup Considerations
1. **VM Backups**
   - Consider adding Proxmox backup configuration
   - Regular snapshots recommended

2. **Configuration Backups**
   - Keep copy of Terraform state
   - Document all custom configurations

## Future Expansion

### Adding Worker Nodes
1. Clone worker node configuration in Terraform
2. Assign new static IP (192.168.0.202+)
3. Update hostname and specific configurations
4. Apply Terraform changes

### Network Capacity Planning
- Current subnet (/24) supports up to 254 hosts
- DHCP range can be adjusted if needed
- Consider VLAN segmentation for larger deployments

## Monitoring & Maintenance

### Regular Checks
1. Network connectivity between nodes
2. MicroK8s cluster health
3. Resource utilization
4. Security updates

### Performance Monitoring
1. Network throughput
2. CPU and memory usage
3. Storage capacity
4. Service response times
