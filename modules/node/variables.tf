variable "environment" {
  description = "Environment name"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "node_config" {
  description = "Configuration for the node"
  type = object({
    name = string
    role = string
    ip_address = string
    vm_id = number
    cpu_cores = number
    memory = number
    disk_size = number
  })
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    gateway_ip = string
    dns_servers = list(string)
    subnet_mask = string
  })
}

variable "cloud_image_file_id" {
  description = "ID of the Ubuntu cloud image"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}