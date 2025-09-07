# Self Signed SSL Create

## Development için SSL oluşturma
*Normal ssl alımlarında, private key oluşturup bu private keyden üretilen bir .csr (certificate sign request) dosyasını alıp para karşılığında, herkes tarafından güvenilen bir CA'ya, CA'nın private keyi ile imzalatmak ve CA.cert ile üretilen User.cert dosyalarıyla fullchain.pem dosyası elde etmek yeterlidir. Ancak bazı durumlarda, özel işler için kendimiz imzalamamız ve developmenta yönelik ssl kullanmamız gerekir.* 

> 1-cert.conf ve csr.conf dosyalarında gerekli ayarlar yapılır.

**cert.config**
```
extendedKeyUsage = serverAuth
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1   = *.example.com
DNS.2   = test.example.com
DNS.3   = localhost
```

**csr.config**
```
# openssl req -new -config myserver.cnf -keyout myserver.key -out myserver.csr

FQDN = localhost
ORGNAME = exampleCompany

[ req ]
default_bits = 4096
default_md = sha256
prompt = no
encrypt_key = no
req_extensions = req_ext
distinguished_name = req_distinguished_name


[req_distinguished_name]
countryName            = TR
stateOrProvinceName    = Ankara
localityName           = Ankara
organizationName       = $ORGNAME
organizationalUnitName = IT
commonName             = $FQDN
emailAddress           = admin@example.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1   = *.example.com
DNS.2   = test.example.com
DNS.3   = localhost
```
> 2-Çalıştırma izni verilerek GenerateSSSL.sh dosyası çalıştırılır.

**GenerateSSSL.sh**
```
    #!/bin/bash
    echo "SELF-SIGN 4096 bit SSL Certificate\n"
    echo "GENERATE: rootCA.key - rootCA.crt\n"
    mkdir NewGeneratedSSL
    # CREATE rootCA.key -out rootCA.crt with RSA---------------------------------------------
    openssl req -x509 \
                -sha256 -days 3560 \
                -nodes \
                -newkey rsa:4096 \
                -subj "/CN=example.xyz/C=TR/L=TR" \
                -keyout NewGeneratedSSL/rootCA.key -out NewGeneratedSSL/rootCA.crt
                


    # Self-Signed User Certificates----------------------------------------------------------
    echo "GENERATE: server.key - server.crt\n"
    openssl genrsa -out NewGeneratedSSL/server.key 4096



    # Create Certificate Sign Request--------------------------------------------------------
    echo "GENERATE: Certificate Sign Request: server.csr\n"
    openssl req -new -key NewGeneratedSSL/server.key -out NewGeneratedSSL/server.csr -config csr.conf



    # Sign own by own------------------------------------------------------------------------
    echo "GENERATE: Sign Certificate own by own: server.crt\n"
    openssl x509 -req \
        -in NewGeneratedSSL/server.csr \
        -CA NewGeneratedSSL/rootCA.crt -CAkey NewGeneratedSSL/rootCA.key \
        -CAcreateserial -out NewGeneratedSSL/server.crt \
        -days 365 \
        -sha256 -extfile cert.conf
        

        
    # FULLCHAIN------------------------------------------------------------------------------
    echo "GENERATE: FullChain: User.crt + rootCA.crt\n"

    cat NewGeneratedSSL/server.crt > NewGeneratedSSL/fullchain.pem
    cat NewGeneratedSSL/rootCA.crt >> NewGeneratedSSL/fullchain.pem



    # Remove Pass----------------------------------------------------------------------------
    echo "GENERATE: Remove Pass: server_without_pass.key\n"
    openssl rsa -in NewGeneratedSSL/server.key -out NewGeneratedSSL/server_without_pass.key

```
> 3-NewGeneratedSSL klasörü içerisinde oluşan fullchain.pem(sertifikaların toplandığı dosya) dosyası ve server.key dosyası, ssl için kullanılır. (server_without_pass.key private anahtarımızın password ile şifrelenmemiş halidir. Eğer gerekli olursa, şifresi kaldırılmış private key kullanılır.)

> 4-Nginx ssl için nginx.config dosyasında 2 adet parametre alır:
```
    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/server_without_pass.key; #server.key olarak adlandırılabilir.
```