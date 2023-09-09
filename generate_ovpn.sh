#!/bin/bash

PATH="/usr/bin"
IFS=" "
OPENVPN_PATH="/etc/openvpn"
EASYRSA_PATH="$OPENVPN_PATH/easy-rsa"
EASYRSA_VARS="$EASYRSA_PATH/vars"
CLIENT_CONF="$OPENVPN_PATH/client.conf"
CA="$OPENVPN_PATH/ca.crt"
TA="$OPENVPN_PATH/ta.key"
KEY_PATH="$EASYRSA_PATH/pki/private"
CERT_PATH="$EASYRSA_PATH/pki/issued"
OVPN_PATH="$OPENVPN_PATH/client-ovpn"

if [[ $# != 1 ]]; then
    echo "Usage: $0 <client-uuid>"
    exit 1
fi

if [[ ! $1 =~ [a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12} ]]; then
    echo "Invalid UUID"
    exit 1
fi

if [[ -f "$OVPN_PATH/$1.ovpn" ]]; then
    cat "$OVPN_PATH/$1.ovpn"
    exit 0
fi

OVPN_FILE="$OVPN_PATH/$1.ovpn"

cd $EASYRSA_PATH
./easyrsa --vars="$EASYRSA_VARS" gen-req $1 nopass &>/dev/null && ./easyrsa --vars="$EASYRSA_VARS" sign-req client $1 &>/dev/null && \
cat $CLIENT_CONF > "$OVPN_FILE" && \
echo "<ca>" >> "$OVPN_FILE" && \
cat "$CA" >> "$OVPN_FILE" && \
echo -e "</ca>\n<cert>" >> "$OVPN_FILE" && \
cat "$CERT_PATH/$1.crt" >> "$OVPN_FILE" && \
echo -e "</cert>\n<key>" >> "$OVPN_FILE" && \
cat "$KEY_PATH/$1.key" >> "$OVPN_FILE" && \
echo -e "</key>\n<tls-auth>" >> "$OVPN_FILE" && \
cat "$TA" >> "$OVPN_FILE" && \
echo "</tls-auth>" >> "$OVPN_FILE" && \
cat "$OVPN_FILE"

exit 0
