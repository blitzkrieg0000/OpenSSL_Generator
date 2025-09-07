#!/bin/bash
# ED25519 SELF-SIGN

CFG_PATH="./config"
WORKDIR="./key"


TIMESTAMP=$(date +"%d%m%Y-%H%M%S")
UUID=$(uuidgen)
WORKDIR="$WORKDIR/${TIMESTAMP}-${UUID}"
mkdir -p "$WORKDIR"


# Create Private Key For CA
echo "[CREATE]: rootCA.key"
openssl genpkey \
    --aes-256-cbc \
    -algorithm ed25519 \
    -out $WORKDIR/rootCA.key


# Create x509 Certificate Via CA Private Key
echo "[CREATE]: rootCA.crt"
openssl req -new -x509 \
    -days 3560 \
    -config $CFG_PATH/ca.cfg \
    -key $WORKDIR/rootCA.key \
    -out $WORKDIR/rootCA.crt


# Create ED25519 Private Key For Server
echo "[CREATE]: server.key"
openssl genpkey \
    -algorithm ed25519 \
    -out $WORKDIR/server.key
    # -pass file:$CFG_PATH/server.pass \


# Create CSR (Certificate Sign Request)
echo "[CREATE]: server.csr"
openssl req -new \
    -config $CFG_PATH/csr.cfg \
    -key $WORKDIR/server.key \
    -out $WORKDIR/server.csr


# Sign Certificate by CA Certificate"
echo "[CREATE]: server.crt"
openssl x509 -req \
    -extfile $CFG_PATH/cert.cfg \
    -CA $WORKDIR/rootCA.crt \
    -CAkey $WORKDIR/rootCA.key \
    -CAcreateserial \
    -in $WORKDIR/server.csr \
    -out $WORKDIR/server.crt \
    -days 3650


# CREATE PFX------------------------------------------------------------------------------
echo "[CREATE]: myservercert.crt [pkcs12]"
openssl pkcs12 -export \
    -inkey $WORKDIR/server.key \
    -in $WORKDIR/server.crt \
    -certfile $WORKDIR/rootCA.crt \
    -out $WORKDIR/myservercert.pfx


# FULLCHAIN------------------------------------------------------------------------------
echo "[CREATE]: fullchain.pem"
cat $WORKDIR/server.crt > $WORKDIR/fullchain.pem
cat $WORKDIR/rootCA.crt >> $WORKDIR/fullchain.pem


# Remove Pass----------------------------------------------------------------------------
echo "[CREATE]: server_without_pass.crt"
if [[ -f "$CFG_PATH/server.pass" ]]; then
    openssl pkey \
        -passin file:"$CFG_PATH/server.pass" \
        -in "$WORKDIR/server.key" \
        -out "$WORKDIR/server_without_pass.key"
fi