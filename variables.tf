variable "environment" {
  description = "Environment name (prod, staging, preprod)"
  type        = string
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "network_config" {
  description = "Network configuration for the cluster"
  type = object({
    gateway_ip = string
    dns_servers = list(string)
    subnet_mask = string
  })
}

variable "nodes" {
  description = "Configuration for all nodes (master and workers)"
  type = list(object({
    name = string
    role = string  # "master" or "worker"
    ip_address = string
    vm_id = number
    cpu_cores = number
    memory = number
    disk_size = number
  }))
}
