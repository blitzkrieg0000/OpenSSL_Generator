#!/bin/bash
CFG_PATH="./config"
WORKDIR="./key"

TIMESTAMP=$(date +"%d%m%Y-%H%M%S")
UUID=$(uuidgen)
WORKDIR="$WORKDIR/${TIMESTAMP}-${UUID}"
mkdir -p "$WORKDIR"


echo "SELF-SIGN 4096 bit SSL Certificate\n"
echo "GENERATE: rootCA.key - rootCA.crt\n"
# CREATE rootCA.key -out rootCA.crt with RSA---------------------------------------------
## Create RSA Private Key For CA
openssl genpkey \
    -algorithm RSA \
    -out $WORKDIR/rootCA.key \
    -pkeyopt rsa_keygen_bits:4096


## Create x509 Certificate Via RSA CA Private Key
openssl req -new -x509 \
        -sha256 \
        -days 3560 \
        -subj "/CN=example.com/C=TR/L=TR" \
        -key $WORKDIR/rootCA.key \
        -out $WORKDIR/rootCA.crt \


# Self-Signed User Certificates----------------------------------------------------------
echo "GENERATE: server.key - server.crt\n"
openssl genrsa -out $WORKDIR/server.key 4096  # -aes256


# Create Certificate Sign Request--------------------------------------------------------
echo "GENERATE: Certificate Sign Request: server.csr\n"
openssl req -new \
    -key $WORKDIR/server.key \
    -out $WORKDIR/server.csr \
    -config $CFG_PATH/csr.cfg


# Sign own by own------------------------------------------------------------------------
echo "GENERATE: Sign Certificate own by own: server.crt\n"
openssl x509 -req \
    -CA $WORKDIR/rootCA.crt \
    -CAkey $WORKDIR/rootCA.key \
    -CAcreateserial \
    -in $WORKDIR/server.csr \
    -out $WORKDIR/server.crt \
    -days 365 \
    -sha256 \
    -extfile $CFG_PATH/cert.cfg
    

# FULLCHAIN------------------------------------------------------------------------------
echo "GENERATE: FullChain: User.crt + rootCA.crt\n"
cat $WORKDIR/server.crt > $WORKDIR/fullchain.pem
cat $WORKDIR/rootCA.crt >> $WORKDIR/fullchain.pem


# Remove Pass----------------------------------------------------------------------------
echo "GENERATE: Remove Pass: server_without_pass.key\n"
openssl rsa -in $WORKDIR/server.key -out $WORKDIR/server_without_pass.key

