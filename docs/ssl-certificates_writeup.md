# How to create a valid self signed SSL Certificate?

**Skills:** Medium - Advanced
**Prerequisites:** none

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

### Optional Stage: View Certificate's Content

```bash
openssl x509 -in ca.pem -text
openssl x509 -in ca.pem -purpose -noout -text
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

```bash
# optional
echo extendedKeyUsage = serverAuth >> extfile.cnf
```

Create the certificate

```bash
openssl x509 -req -sha256 -days 365 -in cert.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -extfile extfile.cnf -CAcreateserial
```

## Certificate Formats

X.509 Certificates exist in Base64 Formats **PEM (.pem, .crt, .ca-bundle)**, **PKCS#7 (.p7b, p7s)** and Binary Formats **DER (.der, .cer)**, **PKCS#12 (.pfx, p12)**.

### Convert Certs

COMMAND | CONVERSION
---|---
`openssl x509 -outform der -in cert.pem -out cert.der` | PEM to DER
`openssl x509 -inform der -in cert.der -out cert.pem` | DER to PEM
`openssl pkcs12 -in cert.pfx -out cert.pem -nodes` | PFX to PEM

## Verify Certificates

`openssl verify -CAfile ca.pem -verbose cert.pem`

## Install the CA Cert as a trusted root CA

### On Debian & Derivatives

- Move the CA certificate (`ca.pem`) into `/usr/local/share/ca-certificates/ca.crt`.

- Update the Cert Store
  
```bash
sudo update-ca-certificates
```

Refer the documentation [here](https://wiki.debian.org/Self-Signed_Certificate) and [here.](https://manpages.debian.org/buster/ca-certificates/update-ca-certificates.8.en.html)

### On Fedora

- Move the CA certificate (`ca.pem`) to `/etc/pki/ca-trust/source/anchors/ca.pem` or `/usr/share/pki/ca-trust-source/anchors/ca.pem`

- Now run (with sudo if necessary)

```bash
update-ca-trust
```

Refer the documentation [here.](https://docs.fedoraproject.org/en-US/quick-docs/using-shared-system-certificates/)

### On Arch

System-wide – Arch(p11-kit)
(From arch wiki)
Run (As root)

```bash
trust anchor --store myCA.crt
```

- The certificate will be written to /etc/ca-certificates/trust-source/myCA.p11-kit and the "legacy" directories automatically updated.
- If you get "no configured writable location" or a similar error, import the CA manually:
- Copy the certificate to the /etc/ca-certificates/trust-source/anchors directory.

Run (As root)

```bash 
update-ca-trust
```

wiki page  [here](https://wiki.archlinux.org/title/User:Grawity/Adding_a_trusted_CA_certificate)

### On Windows

Assuming the path to your generated CA certificate as `C:\ca.pem`, run:

```powershell
Import-Certificate -FilePath "C:\ca.pem" -CertStoreLocation Cert:\LocalMachine\Root
```

- Set `-CertStoreLocation` to `Cert:\CurrentUser\Root` in case you want to trust certificates only for the logged in user.

OR

In Command Prompt, run:

```sh
certutil.exe -addstore root C:\ca.pem
```

- `certutil.exe` is a built-in tool (classic `System32` one) and adds a system-wide trust anchor.

### On Android

The exact steps vary device-to-device, but here is a generalised guide:

1. Open Phone Settings
2. Locate `Encryption and Credentials` section. It is generally found under `Settings > Security > Encryption and Credentials`
3. Choose `Install a certificate`
4. Choose `CA Certificate`
5. Locate the certificate file `ca.pem` on your SD Card/Internal Storage using the file manager.
6. Select to load it.
7. Done!


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