#!/usr/bin/env sh
set -eu

OPENSSL_BIN="/usr/local/Cellar/openssl@3/3.0.7/bin/openssl"
OPENSSL_CNF_SRC="/usr/local/etc/openssl/openssl.cnf"
OPENSSL_CNF="openssl.cnf"
DEMO_CA_DIR="democa"

sed 's/# copyext = copy/copyext = copyall/' "$OPENSSL_CNF_SRC" > "$OPENSSL_CNF"

rm -rf "$DEMO_CA_DIR"
mkdir -p "$DEMO_CA_DIR/newcerts"
printf '01\n' > "$DEMO_CA_DIR/serial"
: > "$DEMO_CA_DIR/index.txt"

"$OPENSSL_BIN" req \
    -newkey rsa:1024 \
    -keyout key.pem \
    -out req.pem \
    -sha256 \
    -nodes \
    -subj "/C=CA/ST=BC/O=roooot.dev/CN=LaraJIT DDI" \
    -addext "basicConstraints=critical, CA:true"

"$OPENSSL_BIN" ca \
    -batch \
    -selfsign \
    -keyfile key.pem \
    -in req.pem \
    -out rawcert.pem \
    -startdate 070416225531Z \
    -enddate 140416225531Z \
    -config "$OPENSSL_CNF"

"$OPENSSL_BIN" x509 \
    -in rawcert.pem \
    -out cert.pem
