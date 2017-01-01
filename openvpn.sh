#!/bin/sh
set -- "$@" '--config' "${REGION:-US East}.ovpn"

if [ ! -f auth.conf ]; then
    echo "${USERNAME:-NONE PROVIDED}" > auth.conf
    echo "${PASSWORD:-NONE PROVIDED}" >> auth.conf
fi
set -- "$@" '--auth-user-pass' 'auth.conf'
set -- "$@" '--auth-nocache'
openvpn "$@"
