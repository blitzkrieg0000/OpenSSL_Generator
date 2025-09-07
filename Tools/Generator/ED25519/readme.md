# CA 
## Create CA-Private-Key
```
$ openssl genrsa -aes256 -out ca_private.pem 4096
```

## Create CA-x509-Certificate From CA-Private-Key
```
$ openssl req -new -x509 -sha256 -days 3650 -key ca_private.pem -out ca_cert.pem
```

## Check CA-X509-Certificate and Show as Text
```
$ openssl x509 -in ca_cert.pem -text -noout
```

.
.
.
# Client 
## Create Server-Private-Key
```
$ openssl genrsa -out server_private.pem 4096
```
## CheckRSA
```
$ openssl rsa -in server_private.pem -text -noout -check
```
## Create Client-CSR via csr.conf file and Encrypt by server_private.pem
```
$ openssl req -new -sha256 -subj "/CN=mywebsite.com" -key server_private.pem -out myserver.csr
$ openssl req -new -config csr.conf -keyout server_private.pem -out myserver.csr
```

.
.
.
# CA-SIGN 
## Verify CSR
```
$ openssl req -text -noout -verify -in myserver.csr
```
## CREATE CA by CSR and ecrypt-sign by CA-KEY
```
$ openssl x509 -req -sha256 -days 3650 -in myserver.csr -CA ca_cert.pem -CAkey ca_private.pem -out myservercert.pem -extfile extfile.cnf -CAcreateserial
```

## Verify Certificate
```
$ openssl verify -CAfile ca_cert.pem -verbose myservercert.pem
```

## Show RSA Details
```
$ openssl x509 -noout -text -in myservercert.pem
```

.
.
.
## Convert 
```
$ openssl x509 -outform der -in myservercert.pem -out myservercert.der
```

```
$ openssl x509 -inform der -in myservercert.der -out myservercert.pem
```

```
$ openssl pkcs12 -export -out myservercert.pfx -inkey 
server_private.pem -in myservercert.pem -certfile ca_cert.pem
```

```
$ openssl pkcs12 -in myservercert.pfx -out myservercert.pem -nodes
```

# Extra 
**Remove a passphrase from a private key**
```
$ openssl rsa -in server_private.pem -out nopass_server_private.pem
```

**Show **CSR** file details**
```
$ openssl req -in RSA-CSR.pem -noout -text
```

**Show **CERT** file details**
```
$ openssl x509 -in wikipedia.cert
```

**Extract Information**
```
$ openssl req -in RSA-CSR.pem -noout -text -dates
```
*-issuer, -subject, -dates, -modulus, -pubkey, -ocsp_uri, -ocspid, -serial, -startdate, -enddate*

**Extract Publickey Info**
```
$ openssl pkey -pubin -noout -text  # and paste public key
```

**Extract Extension Info**
```
$ openssl x509 -in wikipedia.cert -noout -ext subjectAltName
$ openssl x509 -in wikipedia.cert -noout -ext crlDistributionPoints
$ openssl x509 -in wikipedia.cert -noout -ext subjectAltName, crlDistributionPoints
```
*subjectAltName, authorityInfoAccess, crlDistributionPoints, basicConstraints, nameConstraints, certificatePolicies, keyUsage, extendedKeyUsage, subjectKeyIdentifier, authoritKeyIdentifier...*

# Deployments 
## Linux CA Deploy
/usr/local/share/ca-certificates/myserver.crt
```
$ sudo update-ca-certificates
```

## Windows CA Deploy
```
$ Import-Certificate -FilePath "C:\myserver.pem" -CertStoreLocation Cert:\LocalMachine\Root
```
*or*
```
$ certutil.exe -addstore root C:\myserver.pem
```

