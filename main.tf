provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

module "k8s_nodes" {
  source = "./modules/node"
  count  = length(var.nodes)

  providers = {
      proxmox = proxmox
    }
    
  environment         = var.environment
  proxmox_node       = var.proxmox_node
  node_config        = var.nodes[count.index]
  network_config     = var.network_config
  cloud_image_file_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  ssh_public_key     = var.ssh_public_key

  depends_on = [proxmox_virtual_environment_download_file.ubuntu_cloud_image]
}
