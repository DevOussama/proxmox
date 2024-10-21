# Understanding Static IP vs DHCP Reservation

## Scenario

You made a ping to `192.168.0.201` and it worked on the worker node, but you didn't set up `192.168.0.201` with a MAC address in the router settings. Let's understand why it works.

## Key Networking Concepts

### Static IP Assignment vs DHCP Reservation

In your Terraform code, you're setting up the worker node with a static IP (`192.168.0.201`) through cloud-init configuration:

```yaml
write_files:
    - path: /etc/netplan/00-installer-config.yaml
        content: |
            network:
                version: 2
                ethernets:
                    eth0:
                        addresses:
                            - 192.168.0.201/24
```

This is different from DHCP reservation that you see in your router settings. The VM is telling itself "I am `192.168.0.201`" rather than asking the router "What IP should I be?"

### ARP (Address Resolution Protocol)

When devices communicate on a local network, they need to know each other's MAC addresses. The process works like this:

1. Device A wants to ping `192.168.0.201`.
2. Device A broadcasts an ARP request: "Who has `192.168.0.201`?"
3. The worker node responds: "I am `192.168.0.201`, here's my MAC address."
4. Device A caches this information for future communication.

You can actually see this process in action:

```bash
# On any Linux machine in your network, run:
arp -a
```

This will show you the ARP cache, mapping IP addresses to MAC addresses that your machine has discovered.

## Comparison

- **DHCP Reservation (in router)**: The router assigns a specific IP to a MAC address.
- **Static IP (in VM config)**: The device claims an IP address for itself.

As long as:

- The static IP (`192.168.0.201`) is outside your DHCP range (`192.168.0.100-199` in your case).
- No other device is using that IP.

Then everything works fine without needing a DHCP reservation!

## Pros and Cons

### Pros

- Works independently of router configuration.
- Survives router resets/changes.
- Faster network initialization (no need to wait for DHCP).

### Cons

- No centralized IP management.
- Potential for IP conflicts if not carefully managed.
- Less visibility in router's client list.
