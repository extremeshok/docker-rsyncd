#!/usr/bin/env bash

set -e

USERNAME=${USERNAME:-rsync}
PASSWORD=${PASSWORD:-rsync}
ALLOW_IP=${ALLOW_IP:-*}
VOLUME=${VOLUME:-/data}

echo "${USERNAME}:${PASSWORD}" > /etc/rsyncd.secrets
chmod 0400 /etc/rsyncd.secrets

mkdir -p "${VOLUME}"
chown -R "root:root" "$VOLUME"

echo "Generating Config"
cat <<EOF > /etc/rsyncd.conf
pid file = /var/run/rsyncd.pid
log file = /dev/stdout
use chroot = yes
uid = root
gid = root
timeout = 300
max connections = 10
port = 873
reverse lookup = no
transfer logging = yes
ignore nonreadable = yes
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2 *.7z *.7zip *.exe *.rar
[NetBackup]
    hosts deny = *
    hosts allow = ${ALLOW_IP}
    read only = false
    path = ${VOLUME}
    comment = NetBackup ${USERNAME} directory
    auth users = ${USERNAME}
    secrets file = /etc/rsyncd.secrets
[data]
    hosts deny = *
    hosts allow = ${ALLOW_IP}
    read only = false
    path = ${VOLUME}
    comment = Data ${USERNAME} directory
    auth users = ${USERNAME}
    secrets file = /etc/rsyncd.secrets
[Backup]
    hosts allow = ${ALLOW_IP}
    hosts deny = *
    read only = false
    path = ${VOLUME}
    comment = Backup ${USERNAME} directory
    auth users = ${USERNAME}
    secrets file = /etc/rsyncd.secrets
[MyCloud]
    hosts allow = ${ALLOW_IP}
    hosts deny = *
    read only = false
    path = ${VOLUME}
    comment = MyCloud ${USERNAME} directory
    auth users = ${USERNAME}
    secrets file = /etc/rsyncd.secrets
EOF

exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
