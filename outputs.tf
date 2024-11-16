# output "node_ips" {
#   description = "IP addresses of all nodes"
#   value = {
#     for idx, node in module.k8s_nodes : var.nodes[idx].name => node.node_ip
#   }
# }