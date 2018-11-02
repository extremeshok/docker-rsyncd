#!/bin/bash
set -e

USERNAME=${USERNAME:-rsync}
PASSWORD=${PASSWORD:-rsync}
ALLOW_IP=${ALLOW_IP:-*}
VOLUME=${VOLUME:-/data}

echo "${USERNAME}:${PASSWORD}" > /etc/rsyncd.secrets
chmod 0400 /etc/rsyncd.secrets

mkdir -p "${VOLUME}/${USERNAME}"
chown -R "root:root" "$VOLUME"

cat <<EOF > /etc/rsyncd.conf
  pid file = /var/run/rsyncd.pid
  log file = /dev/stdout
  uid = root
  gid = root
  timeout = 300
  max connections = 10
  port = 873
  reverse lookup = no
  use chroot = yes
  transfer logging = yes
  ignore nonreadable = yes
  dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2 *.7z *.7zip *.exe *.rar
  hosts deny = *
  hosts allow = ${ALLOW_IP}
  read only = false
  [NetBackup]
      path = ${VOLUME}
      comment = NetBackup ${USERNAME} directory
      auth users = ${USERNAME}
      secrets file = /etc/rsyncd.secrets
  [data]
      path = ${VOLUME}
      comment = Data ${USERNAME} directory
      auth users = ${USERNAME}
      secrets file = /etc/rsyncd.secrets
  [Backup]
      path = ${VOLUME}
      comment = Backup ${USERNAME} directory
      auth users = ${USERNAME}
      secrets file = /etc/rsyncd.secrets
  [MyCloud]
      path = ${VOLUME}
      comment = MyCloud ${USERNAME} directory
      auth users = ${USERNAME}
      secrets file = /etc/rsyncd.secrets
EOF

exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
