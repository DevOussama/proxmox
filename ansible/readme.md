# Ansible Playbooks for MicroK8s Cluster Management

## Overview

This set of Ansible playbooks is designed to manage a MicroK8s Kubernetes cluster. The playbooks cover the setup of the master node, addition of new worker nodes, and removal of worker nodes from the cluster.

## Playbooks

### 1. Setup Master Node

This playbook sets up the master node for the MicroK8s cluster.

**Usage:**
```bash
ansible-playbook setup-master.yml
```

### 2. Add New Worker Nodes

This playbook adds new worker nodes to the MicroK8s cluster. Update `inventory.yml` with new workers under the `new_workers` group before running this playbook.

**Usage:**
```bash
ansible-playbook setup-worker.yml
```

### 3. Remove Worker Nodes

This playbook removes worker nodes from the MicroK8s cluster. Update `inventory.yml` with nodes to remove under the `remove_workers` group before running this playbook.

**Usage:**
```bash
ansible-playbook remove-worker.yml
```

## Updating Inventory

To add new worker nodes, update the `inventory.yml` file by adding the new worker nodes under the `new_workers` group. For example:

```yaml
[new_workers]
worker1 ansible_host=192.168.1.2
worker2 ansible_host=192.168.1.3
```

To remove worker nodes, update the `inventory.yml` file by adding the nodes to remove under the `remove_workers` group. For example:

```yaml
[remove_workers]
worker1 ansible_host=192.168.1.2
worker2 ansible_host=192.168.1.3
```


networking :
sudo iptables -A INPUT -p tcp --dport 16443 -j ACCEPT
sudo iptables -L -n | grep 16443
