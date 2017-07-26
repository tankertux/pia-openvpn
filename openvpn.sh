#!/bin/sh
set -e -u -o pipefail


if [ -n "$REGION" ]; then
  set -- "$@" '--config' "${REGION}.ovpn"
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

if [ -n "$LOCAL_NETWORK" ] ; then
    ip route add `ip route | sed -n "/^default/ s#default#$LOCAL_NETWORK#p"`
fi


openvpn "$@"

