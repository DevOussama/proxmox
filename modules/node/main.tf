locals {
  full_ip_address = "${var.node_config.ip_address}/${var.network_config.subnet_mask}"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init.yml.tpl", {
      ssh_public_key = var.ssh_public_key
      hostname       = var.node_config.name
      ip_address     = local.full_ip_address
      gateway_ip     = var.network_config.gateway_ip
      dns_servers    = var.network_config.dns_servers
      node_role      = var.node_config.role
    })
    file_name = "cloud-config-${var.node_config.name}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  name        = "microk8s-${var.node_config.name}-${var.environment}"
  description = "MicroK8s ${title(var.node_config.role)} Node - ${var.environment}"
  tags        = ["terraform", "microk8s", var.node_config.role, var.environment]

  node_name = var.proxmox_node
  vm_id     = var.node_config.vm_id
  
  agent {
    enabled = true
  }
  
  startup {
    order      = var.node_config.role == "master" ? "1" : "2"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = var.node_config.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.node_config.memory
    floating  = var.node_config.memory
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = var.cloud_image_file_id
    interface    = "scsi0"
    size         = var.node_config.disk_size
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
        address = local.full_ip_address
        gateway = var.network_config.gateway_ip
      }
    }
  }
}
