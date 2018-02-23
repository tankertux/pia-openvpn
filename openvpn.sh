#!/bin/sh
set -e -u -o pipefail
path="pia-standard"

if [ ${STRONG_ENCRYPT:-false} ] ; then
  path="pia-strong"
fi

if [ -n "$REGION" ]; then
  # eliminate issues with whitespace in filenames
  cp "${path}/${REGION}.ovpn" config.ovpn
  set -- "$@" '--config' "config.ovpn"
fi

if [ -n "${USERNAME-}" ]&& [ -n "${PASSWORD-}" ] ; then
    echo "USERNAME is set and is not empty"
    echo "$USERNAME" > /etc/openvpn/auth.conf
    echo "$PASSWORD" >> /etc/openvpn/auth.conf
    set -- "$@" '--auth-user-pass' 'auth.conf' '--auth-nocache'
else
    echo "USERNAME is not set"
    set -- "$@" '--auth-user-pass' 'auth.conf' '--auth-nocache'
fi

if [ -n "${LOCAL_NETWORK:-}" ] ; then
    ip route add `ip route | sed -n "/^default/ s#default#$LOCAL_NETWORK#p"`
fi


openvpn "$@"
