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

# Master node cloud-init configuration
# resource "proxmox_virtual_environment_file" "cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "node2"

#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     chpasswd:
#       list: |
#         ubuntu:password
#       expire: false
#     hostname: master_node
#     packages:
#       - qemu-guest-agent
#       - openssh-server
#     users:
#       - default
#       - name: ubuntu
#         groups: sudo
#         shell: /bin/bash
#         ssh-authorized-keys:
#           - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     write_files:
#       - path: /etc/netplan/00-installer-config.yaml
#         content: |
#           network:
#             version: 2
#             ethernets:
#               eth0:
#                 addresses:
#                   - 192.168.0.200/24
#                 gateway4: 192.168.0.1
#                 nameservers:
#                   addresses: [192.168.0.1]
#     runcmd:
#       - netplan apply
#       - systemctl enable qemu-guest-agent
#       - systemctl start qemu-guest-agent
#       - echo "master-node" > /etc/hostname
#       - hostnamectl set-hostname master-node
#       - sudo snap install microk8s --classic --channel=1.31
#       - sudo usermod -a -G microk8s ubuntu
#       - sudo chown -R ubuntu ~/.kube
#       - sudo microk8s status --wait-ready
#       - sudo microk8s enable dns dashboard
#       - sudo microk8s config > /home/ubuntu/.kube/config
#       - sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
#       - echo "Master node setup completed" > /home/ubuntu/master-setup-complete
#     EOF

#     file_name = "cloud-config-master.yaml"
#   }
# }

# # Worker node cloud-init configuration
# resource "proxmox_virtual_environment_file" "cloud_config_worker" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "node2"

#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     chpasswd:
#       list: |
#         ubuntu:password
#       expire: false
#     hostname: worker_node_1
#     packages:
#       - qemu-guest-agent
#       - openssh-server
#     users:
#       - default
#       - name: ubuntu
#         groups: sudo
#         shell: /bin/bash
#         ssh-authorized-keys:
#           - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     write_files:
#       - path: /etc/netplan/00-installer-config.yaml
#         content: |
#           network:
#             version: 2
#             ethernets:
#               eth0:
#                 addresses:
#                   - 192.168.0.201/24
#                 gateway4: 192.168.0.1
#                 nameservers:
#                   addresses: [192.168.0.1]
#       - path: /home/ubuntu/join-cluster.sh
#         permissions: '0755'
#         content: |
#           #!/bin/bash
#           # Wait for master node to be ready
#           while ! ssh -o StrictHostKeyChecking=no ubuntu@192.168.0.200 "test -f /home/ubuntu/master-setup-complete"; do
#             echo "Waiting for master node to complete setup..."
#             sleep 30
#           done
#           # Get join command from master node
#           JOIN_COMMAND=$(ssh -o StrictHostKeyChecking=no ubuntu@192.168.0.200 'sudo microk8s add-node --token-ttl 0' | grep 'microk8s join' | head -n1)
#           # Execute join command
#           sudo $JOIN_COMMAND
#     runcmd:
#       - netplan apply
#       - systemctl enable qemu-guest-agent
#       - systemctl start qemu-guest-agent
#       - echo "worker-node-1" > /etc/hostname
#       - hostnamectl set-hostname worker-node-1
#       - sudo snap install microk8s --classic --channel=1.31
#       - sudo usermod -a -G microk8s ubuntu
#       - sudo microk8s status --wait-ready
#       - su - ubuntu -c "/home/ubuntu/join-cluster.sh"
#     EOF

#     file_name = "cloud-config-worker.yaml"
#   }
# }

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
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
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
    ip_config {
      ipv4 {
        address = "192.168.0.200/24"
        gateway = "192.168.0.1"
      }
    }
    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = "TT123456!"
      username = "ubuntu"
    }
    # user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
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
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
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
    ip_config {
      ipv4 {
        address = "192.168.0.201/24"
        gateway = "192.168.0.1"
      }
    }
    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = "TT123456!"
      username = "ubuntu"
    }
    # user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker.id
  }
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_qcow2_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "node2"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "local_file" "ubuntu_vm_password_file" {
  content  = random_password.ubuntu_vm_password.result
  filename = "${path.module}/ubuntu_vm_password.txt"
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}
