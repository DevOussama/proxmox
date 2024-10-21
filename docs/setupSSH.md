For more detailed instructions, you can refer to the following parts of the guide:

- [Deploying Kubernetes Cluster on Proxmox - Part 1](https://olav.ninja/deploying-kubernetes-cluster-on-proxmox-part-1)
- [Deploying Kubernetes Cluster on Proxmox - Part 2](https://olav.ninja/deploying-kubernetes-cluster-on-proxmox-part-2)


## Creating SSH Key and Connecting to Remote VM

### Creating SSH Key on Windows

1. Open PowerShell.
2. Generate a new SSH key pair:
    ```sh
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```
3. Follow the prompts to save the key (default location is usually fine) and set a passphrase.

### Creating SSH Key on Linux

1. Open a terminal.
2. Generate a new SSH key pair:
    ```sh
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```
3. Follow the prompts to save the key (default location is usually fine) and set a passphrase.

### Adding SSH Key to SSH Agent

1. Start the SSH agent:
    - On Windows:
      ```sh
      Start-Service ssh-agent
      ```
    - On Linux:
      ```sh
      eval "$(ssh-agent -s)"
      ```
2. Add your SSH private key to the SSH agent:
    ```sh
    ssh-add ~/.ssh/id_rsa
    ```

### Copying SSH Key to Remote VM

1. Use `ssh-copy-id` to copy your SSH key to the remote VM:
    ```sh
    ssh-copy-id user@remote_host
    ```
    Replace `user` with your username and `remote_host` with the IP address or hostname of your VM.

### Connecting to Remote VM

1. Connect to the remote VM using SSH:
    - On Windows, specify the path of the SSH private key:
      ```sh
      ssh -i C:\Users\otanf\.ssh\id_rsa user@remote_host
      ```
      Replace `user` with your username and `remote_host` with the IP address or hostname of your VM.
    - On Linux:
      ```sh
      ssh -i ~/.ssh/id_rsa user@remote_host
      ```
      Replace `user` with your username and `remote_host` with the IP address or hostname of your VM.
  