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

# resource "proxmox_virtual_environment_file" "cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "node2"

#   source_file {
#     path = "cloud-init/user-data.yml"
#   }
# }

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node2"

  source_raw {
    data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        ubuntu:password
      expire: false
    hostname: master_node
    packages:
      - qemu-guest-agent
      - openssh-server
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPGGEn2DJJIYmHwEyNaytWGaBsXIHZtOTjev4GwMHMJOQ5xsVB20rs2rVjqoLujlOtqbR+GEvpWYI0LgqJ4UyUDmjgXVjXBGB0gsw/Rb/lbVf2/28MARozBAijF+G4D1wQ/tfphxnAKUEo11NWxpHj5ZFGtJ3VjDm44G+esJDntqwZl+EViOMd9fbflILhQd1JIioh/cLMxLrElnxD6DRXRDSHT7Xvib6zff5/imNO7TpDfPnItv5kgq1cU1BdkaZwFqRMKIHRfloxgPrplpfVm/3PRhfop9KQv9yA/mlfbC92xnErbu2ar9iiGnrOsmlSstiP32hFg3PFVXs+AFxQr6Fc7mvmoc0D00mnbgIOmKRLBYyDBPieKOqhkWQ29h+9QXP79w60kjnm/gv0ym9/uVAuns2TX0xmmmB4EIVwvrkoDd4bAODQ9pEo+OhLvVM4P/yb1uiXJ+UxxcHMZovgIHEEn3yDbPkSJ/DzzZI55haZQI7sHPCqtfCdk7yQ3lDmaCrZ2H6SP6LBlqJ/ap08EPoljJIMtKgfEVQUHZpiviAlUq8x2spgT7hcWCf50WgyTONiISNsf7uvDwT3qnU1QsyATqVGGF+lwyw1HASv/KhZwFFTBWkYPsKQXgVac+cuY+47a0Eg0oLB/ti8+HrRVpQ+expPmmMpLAgl0UHD8w== otanfous@gmail.com
        sudo: ALL=(ALL) NOPASSWD:ALL
    write_files:
      - path: /etc/netplan/00-installer-config.yaml
        content: |
          network:
            version: 2
            ethernets:
              eth0:
                addresses:
                  - 192.168.0.200/24
                gateway4: 192.168.0.1
                nameservers:
                  addresses: [192.168.0.1]
    runcmd:
      - netplan apply
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "master-node" > /etc/hostname
      - hostnamectl set-hostname master-node
      - sudo snap install microk8s --classic --channel=1.31
      - sudo usermod -a -G microk8s ubuntu
      - sudo chown -R ubuntu ~/.kube
      - sudo microk8s status --wait-ready
      - sudo microk8s enable dns dashboard
      - sudo microk8s config > /home/ubuntu/.kube/config
      - sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
      - echo "Master node setup completed" > /home/ubuntu/master-setup-complete
    EOF

    file_name = "cloud-config-master.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_worker" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "node2"

  source_raw {
    data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        ubuntu:password
      expire: false
    hostname: worker_node
    packages:
      - qemu-guest-agent
      - openssh-server
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPGGEn2DJJIYmHwEyNaytWGaBsXIHZtOTjev4GwMHMJOQ5xsVB20rs2rVjqoLujlOtqbR+GEvpWYI0LgqJ4UyUDmjgXVjXBGB0gsw/Rb/lbVf2/28MARozBAijF+G4D1wQ/tfphxnAKUEo11NWxpHj5ZFGtJ3VjDm44G+esJDntqwZl+EViOMd9fbflILhQd1JIioh/cLMxLrElnxD6DRXRDSHT7Xvib6zff5/imNO7TpDfPnItv5kgq1cU1BdkaZwFqRMKIHRfloxgPrplpfVm/3PRhfop9KQv9yA/mlfbC92xnErbu2ar9iiGnrOsmlSstiP32hFg3PFVXs+AFxQr6Fc7mvmoc0D00mnbgIOmKRLBYyDBPieKOqhkWQ29h+9QXP79w60kjnm/gv0ym9/uVAuns2TX0xmmmB4EIVwvrkoDd4bAODQ9pEo+OhLvVM4P/yb1uiXJ+UxxcHMZovgIHEEn3yDbPkSJ/DzzZI55haZQI7sHPCqtfCdk7yQ3lDmaCrZ2H6SP6LBlqJ/ap08EPoljJIMtKgfEVQUHZpiviAlUq8x2spgT7hcWCf50WgyTONiISNsf7uvDwT3qnU1QsyATqVGGF+lwyw1HASv/KhZwFFTBWkYPsKQXgVac+cuY+47a0Eg0oLB/ti8+HrRVpQ+expPmmMpLAgl0UHD8w== otanfous@gmail.com
        sudo: ALL=(ALL) NOPASSWD:ALL
    write_files:
      - path: /etc/netplan/00-installer-config.yaml
        content: |
          network:
            version: 2
            ethernets:
              eth0:
                addresses:
                  - 192.168.0.201/24
                gateway4: 192.168.0.1
                nameservers:
                  addresses: [192.168.0.1]
    runcmd:
      - netplan apply
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "worker-node" > /etc/hostname
      - hostnamectl set-hostname worker-node
      - sudo snap install microk8s --classic --channel=1.31
      - sudo usermod -a -G microk8s ubuntu
      - sudo chown -R ubuntu ~/.kube
      - sudo microk8s status --wait-ready
      - sudo microk8s enable dns dashboard
      - sudo microk8s config > /home/ubuntu/.kube/config
      - sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
      - echo "Worker node setup completed" > /home/ubuntu/worker-setup-complete
    EOF

    file_name = "cloud-config-worker.yaml"
  }
}

# Master node VM configuration
resource "proxmox_virtual_environment_vm" "master_node" {
  name        = "microk8s-master-node"
  description = "MicroK8s Master Node"
  tags        = ["terraform", "microk8s", "master"]

  node_name = "node2"
  vm_id     = 4320
  
  agent {
    enabled = true
  }
  
  startup {
    order      = "1"  # Start first
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    ip_config {
      ipv4 {
        address = "192.168.0.200/24"
        gateway = "192.168.0.1"
      }
    }

  }
}

# Worker node VM configuration
resource "proxmox_virtual_environment_vm" "worker_node" {
  name        = "microk8s-worker-node-1"
  description = "MicroK8s Worker Node 1"
  tags        = ["terraform", "microk8s", "worker"]
  
  depends_on = [proxmox_virtual_environment_vm.master_node]  # Explicit dependency

  node_name = "node2"
  vm_id     = 4322
  
  agent {
    enabled = true
  }

  startup {
    order      = "2"  # Start after master
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker.id
    ip_config {
      ipv4 {
        address = "192.168.0.201/24"
        gateway = "192.168.0.1"
      }
    }

  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "node2"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
