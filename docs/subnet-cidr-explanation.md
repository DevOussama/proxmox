# Understanding /24 in IP Addressing
## A Comprehensive Guide to Subnet Masks and CIDR Notation

### 1. What is /24?

#### CIDR Notation Explained
- /24 is CIDR (Classless Inter-Domain Routing) notation
- Represents the number of bits used for the network portion of the address
- In binary: 11111111.11111111.11111111.00000000
- Equivalent to subnet mask: 255.255.255.0

```ascii
IP Address: 192.168.0.200
CIDR: /24
│           Network           │    Host    │
└────────────────────────────┴────────────┘
11000000.10101000.00000000   .11001000
    192  .   168  .   0      .   200
```

### 2. Why /24?

#### Mathematical Breakdown
```
Total bits in IPv4 address: 32
Network bits (/24): 24
Host bits: 32 - 24 = 8
Available host addresses: 2^8 - 2 = 254
- Subtract 2 because:
  * First address (192.168.0.0) = Network address
  * Last address (192.168.0.255) = Broadcast address
```

#### Network Range for 192.168.0.0/24
```
Network Address: 192.168.0.0
First Usable IP: 192.168.0.1    (Your Router)
Last Usable IP:  192.168.0.254
Broadcast:       192.168.0.255
Total Usable:    254 IP addresses
```

### 3. Your Network Layout with /24

#### Address Allocation
```
192.168.0.1      - Router/Gateway
192.168.0.100-199 - DHCP Range (100 addresses)
192.168.0.200    - Master Node
192.168.0.201    - Worker Node
```

```ascii
┌──────────────────────────────────────────────────────┐
│ 192.168.0.0/24 Network                              │
│                                                      │
│ ┌─────────┐   ┌───────────────┐   ┌───────────────┐ │
│ │Reserved │   │  DHCP Range   │   │Static IPs     │ │
│ │1-99     │   │  100-199      │   │200-254        │ │
│ └─────────┘   └───────────────┘   └───────────────┘ │
└──────────────────────────────────────────────────────┘
```

### 4. Alternative Subnet Sizes

#### Comparison of Common CIDR Notations
```
/16 (255.255.0.0):    65,534 hosts
/24 (255.255.255.0):  254 hosts
/25 (255.255.255.128): 126 hosts
/26 (255.255.255.192): 62 hosts
```

#### Why Not Other Sizes?
1. **/16 (Too Large)**
   - 65,534 possible hosts
   - Excessive for home/small office
   - Wastes address space
   - Larger broadcast domain

2. **/25 (Too Small)**
   - Only 126 usable addresses
   - Limited room for expansion
   - Might need to renumber network later

3. **/24 (Just Right)**
   - 254 usable addresses
   - Standard for small networks
   - Easy to calculate and remember
   - Plenty of room for growth

### 5. Practical Impact of /24

#### Benefits in Your Setup
1. **Clean Division**
   ```
   Infrastructure: 192.168.0.1-99    (99 addresses)
   DHCP Pool:     192.168.0.100-199  (100 addresses)
   Static IPs:    192.168.0.200-254  (55 addresses)
   ```

2. **Easy Management**
   - Simple to remember range
   - Standard configuration
   - Compatible with most network equipment

3. **Future Expansion**
   - Room for additional nodes
   - Space for new services
   - Flexible allocation

### 6. Implementation in Your Network

#### Router Configuration
```
IP Address: 192.168.0.1
Subnet Mask: 255.255.255.0 (/24)
Network: 192.168.0.0
Broadcast: 192.168.0.255
```

#### VM Configuration
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.0.200/24  # Master Node
        - 192.168.0.201/24  # Worker Node
      gateway4: 192.168.0.1
```

### 7. Troubleshooting Network Range

#### Verify Subnet Configuration
```bash
# On Linux systems
ip addr show

# Expected output example
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.0.200/24 brd 192.168.0.255 scope global eth0
```

#### Check Network Range
```bash
# Calculate network range
ipcalc 192.168.0.0/24

# Output
Network:   192.168.0.0/24
Broadcast: 192.168.0.255
HostMin:   192.168.0.1
HostMax:   192.168.0.254
```
