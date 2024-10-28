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
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - echo "Hello, World!" > /tmp/hello.txt  
      - sudo snap install microk8s --classic --channel=1.31
      - sudo microk8s status --wait-ready
      - sudo microk8s enable dns dashboard
    EOF

    file_name = "cloud-config-master.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "master_node" {
  name        = "microk8s-master-node"
  description = "MicroK8s Master Node"
  tags        = ["terraform", "microk8s", "master"]

  node_name = "node2"
  vm_id     = 4320
  agent {
    enabled = false
  }
  stop_on_destroy = true

  startup {
    order      = "3"
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
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.100/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = "TT123456!"
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}


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
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - echo "Hello, World!" > /tmp/hello.txt  
      - sudo snap install microk8s --classic --channel=1.31
      - sudo microk8s status --wait-ready
      - JOIN_COMMAND=$(ssh ubuntu@192.168.1.100 'sudo microk8s add-node' | grep 'microk8s join')
      - sudo $JOIN_COMMAND
      - sudo microk8s kubectl get nodes
     
    EOF

    file_name = "cloud-config-worker.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "worker_node" {
  name        = "microk8s-worker-node"
  description = "MicroK8s Worker Node"
  tags        = ["terraform", "microk8s", "worker"]

  node_name = "node2"
  vm_id     = 4322
  agent {
    enabled = false
  }
  stop_on_destroy = true

  startup {
    order      = "3"
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
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = "TT123456!"
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

}


resource "proxmox_virtual_environment_file" "cloud_config_worker_2" {
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
    hostname: worker_node_2
    packages:
      - qemu-guest-agent
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - echo "Hello, World!" > /tmp/hello.txt  
      - sudo snap install microk8s --classic --channel=1.31
      - sudo microk8s status --wait-ready
      - JOIN_COMMAND=$(ssh ubuntu@192.168.1.100 'sudo microk8s add-node' | grep 'microk8s join')
      - sudo $JOIN_COMMAND
      - sudo microk8s kubectl get nodes
    EOF

    file_name = "cloud-config-worker-2.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "worker_node_2" {
  name        = "microk8s-worker-node-2"
  description = "MicroK8s Worker Node-2"
  tags        = ["terraform", "microk8s", "worker"]

  node_name = "node2"
  vm_id     = 4324
  agent {
    enabled = false
  }
  stop_on_destroy = true

  startup {
    order      = "3"
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
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = "TT123456!"
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker_2.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

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
