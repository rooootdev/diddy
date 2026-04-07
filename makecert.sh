#!/usr/bin/env sh
set -eu

OPENSSL_BIN=$(command -v openssl)
OPENSSL_CNF="./ca.cnf"
DEMO_CA_DIR="./democa"
KEY_FILE="key.pem"
REQ_FILE="req.pem"
CERT_FILE="cert.pem"

if [ ! -f "$OPENSSL_CNF" ]; then
    echo "ca.cnf not found in current directory!"
    exit 1
fi

rm -rf ./certstuff
mkdir ./certstuff
cd ./certstuff

rm -rf "$DEMO_CA_DIR"
mkdir -p "$DEMO_CA_DIR/newcerts"
printf '01\n' > "$DEMO_CA_DIR/serial"
: > "$DEMO_CA_DIR/index.txt"

"$OPENSSL_BIN" req -new \
    -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$REQ_FILE" \
    -sha256 \
    -nodes \
    -subj "/C=CA/ST=BC/O=roooot.dev/CN=LaraJIT DDI" \
    -addext "basicConstraints=critical, CA:true"

"$OPENSSL_BIN" ca \
    -batch \
    -selfsign \
    -keyfile "$KEY_FILE" \
    -in "$REQ_FILE" \
    -out "$CERT_FILE" \
    -startdate 070416225531Z \
    -enddate 140416225531Z \
    -config "./../$OPENSSL_CNF"

echo "key:  $KEY_FILE"
echo "cert: $CERT_FILE"