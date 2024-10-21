## Self-Signed Certificates

### Generate CA

Generate RSA

```bash
openssl genrsa -aes256 -out ca-key.pem 4096
```

Generate a public CA Cert

```bash
openssl req -new -x509 -sha256 -days 365 -key ca-key.pem -out ca.pem
```

### Generate Certificate

Create a RSA key

```bash
openssl genrsa -out cert-key.pem 4096
```

Create a Certificate Signing Request (CSR)

```bash
openssl req -new -sha256 -subj "/CN=yourcn" -key cert-key.pem -out cert.csr
```

Create a `extfile` with all the alternative names

```bash
echo "subjectAltName=DNS:your-dns.record,IP:257.10.10.1" >> extfile.cnf
```

Create the certificate

```bash
openssl x509 -req -sha256 -days 365 -in cert.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -extfile extfile.cnf -CAcreateserial
```
## Install the CA Cert as a trusted root CA
### On Windows

Assuming the path to your generated CA certificate as `C:\ca.pem`, run:

```powershell
Import-Certificate -FilePath "C:\ca.pem" -CertStoreLocation Cert:\LocalMachine\Root
```

## Using Certificates in Proxmox

### Combine Certificates

Concatenate the certificate and CA certificate into a single file:

```bash
cat cert.pem > fullchain.pem
cat ca.pem >> fullchain.pem
```

### Upload to Proxmox

1. Copy the output of the following command into the Proxmox top field:

    ```bash
    cat cert-key.pem
    ```

2. Copy the output of the following command into the Proxmox bottom field:

    ```bash
    cat fullchain.pem
    ```

This will ensure that Proxmox uses the correct certificate and key for SSL/TLS.


For a detailed video tutorial on setting up SSL certificates, refer to [this YouTube video](https://www.youtube.com/watch?v=VH4gXcvkmOY).