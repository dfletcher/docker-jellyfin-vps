#!/bin/bash

function mandatory(){
  variable=${1}
  if [[ -z "${!variable}" ]]; then
    echo "----------------------------------------------------------------------"
    echo "Environment variable ${variable} is not set. Either the"
    echo "required .env file does not exist, or the variable"
    echo "----------------------------------------------------------------------"
    exit 1
  fi
}

# Variables.
mandatory REMOTE_HOST
mandatory REMOTE_USER

# Tunnel source host. Default = jellyfin
TUNNEL_SOURCE_HOST=${TUNNEL_SOURCE_HOST:-jellyfin}

# Tunnel source port. Default = 8096
TUNNEL_SOURCE_PORT=${TUNNEL_SOURCE_PORT:-8096}

# Tunnel remote host. Default = 0.0.0.0
TUNNEL_REMOTE_HOST=${TUNNEL_REMOTE_HOST:-0.0.0.0}

# Tunnel remote port. Default = 8096
TUNNEL_REMOTE_PORT=${TUNNEL_REMOTE_PORT:-8096}

# Type of key to generate. Default = rsa
GENERATED_KEY_TYPE=${GENERATED_KEY_TYPE:-rsa}

# Size of generated key. Default = 2048
GENERATED_KEY_SIZE=${GENERATED_KEY_SIZE:-2048}

# Ssh home directory. Default = /root/.ssh
SSH_HOME_DIR=${SSH_HOME_DIR:-/root/.ssh}

# Else ssh gets grumpy.
mkdir -p ${SSH_HOME_DIR}
chmod 0770 ${SSH_HOME_DIR}

# Generate key if we don't have one.
if ! [[ -f "/keys/id_rsa" ]]; then
  ssh-keygen -t${GENERATED_KEY_TYPE} -b${GENERATED_KEY_SIZE} -q -f "/keys/id_${GENERATED_KEY_TYPE}" -N ""
fi

# Can't change permissions on Windows shares so copy the files from /keys dir bind mount.
cp /keys/id_${GENERATED_KEY_TYPE}* ${SSH_HOME_DIR}/
chmod 0600 "${SSH_HOME_DIR}/id_${GENERATED_KEY_TYPE}"
chmod 0644 "${SSH_HOME_DIR}/id_${GENERATED_KEY_TYPE}.pub"

# Avoid interactive prompt by adding REMOTE_HOST to known hosts.
if ! grep "${REMOTE_HOST}" "${SSH_HOME_DIR}/known_hosts"; then
  ssh-keyscan -H "${REMOTE_HOST}" >> "${SSH_HOME_DIR}/known_hosts";
fi

# Tunnel.
echo "Starting tunnel: ${TUNNEL_SOURCE_HOST}:${TUNNEL_SOURCE_PORT} -> ${TUNNEL_REMOTE_HOST}:${TUNNEL_REMOTE_PORT} at ${REMOTE_HOST}..."
if ! ssh -vvv -N -R "${TUNNEL_REMOTE_HOST}:${TUNNEL_REMOTE_PORT}:${TUNNEL_SOURCE_HOST}:${TUNNEL_SOURCE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}"; then
  echo "Could not connect to server ${REMOTE_HOST}. Please add the following"
  echo "public key to ${REMOTE_USER}@${REMOTE_HOST}:~/.ssh/authorized_keys"
  echo "and ensure the remote server can be reached from your host."
  cat "${SSH_HOME_DIR}/id_${GENERATED_KEY_TYPE}.pub"
fi
