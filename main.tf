provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
}

module "k8s_nodes" {
  source = "./modules/node"
  count  = length(var.nodes)

  providers = {
      proxmox = proxmox
    }
    
  environment         = var.environment
  node_config        = var.nodes[count.index]
  network_config     = var.network_config
  ssh_public_key     = var.ssh_public_key

}
