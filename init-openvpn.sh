#!/bin/bash

set -e

EASYRSA_DIR=/etc/openvpn/easy-rsa
OPENVPN_DIR=/etc/openvpn

# Initialize PKI and generate server certificates
cd $EASYRSA_DIR
./easyrsa init-pki

# Build CA
./easyrsa build-ca nopass

# Generate server request and sign it
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Generate Diffie-Hellman key
./easyrsa gen-dh

# Generate a shared TLS key
openvpn --genkey --secret $OPENVPN_DIR/ta.key

# Generate client request and sign it
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

# Move all necessary files to the OpenVPN directory
cp $EASYRSA_DIR/pki/ca.crt $OPENVPN_DIR
cp $EASYRSA_DIR/pki/private/server.key $OPENVPN_DIR
cp $EASYRSA_DIR/pki/issued/server.crt $OPENVPN_DIR
cp $EASYRSA_DIR/pki/dh.pem $OPENVPN_DIR
cp $OPENVPN_DIR/ta.key $OPENVPN_DIR

# Create server.conf
cat << EOF > $OPENVPN_DIR/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
EOF

# Start the OpenVPN server
exec "$@"
