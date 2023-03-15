#!/bin/bash

echo "[*] Triggered Phantom/SOAR backup"

# Switch to a working directory
cd /opt/phantom

#TODO: A working detection is needed
privileged=0
if [ "${privileged}" -eq 1 ]; then
   sudowrapper="sudo"
else
   sudowrapper="sudo -u phantom -g phantom"
fi

# We need to remove any fancy ANSI colors from the output
PHANTOM_VERSION=$(${sudowrapper} /opt/phantom/bin/phenv phantom_version | sed -e 's/\x1b\[[0-9;]*m//g')

echo "[*] Identified Phantom/SOAR version: ${PHANTOM_VERSION}"

# Get the backup path
BACKUP_PATH=$(${sudowrapper} /opt/phantom/bin/phenv ibackup --backup --config-only 2>/dev/null | grep 'Backup located at' | sed 's/Backup located at \(.*\)/\1/')

echo "[*] Backup available at ${BACKUP_PATH}"

# If there's a path, copy it outside the VM
if sudo test -r "${BACKUP_PATH}"; then
  echo "[*] Copying the backup file outside the VM, if all is set well"
  echo "[*]   Check backup/${PHANTOM_VERSION} folder in your vagrant-phantom"
  # Just in case, maybe it's already there
  sudo mkdir -p /vagrant/backup/${PHANTOM_VERSION}
  # Copy the backup
  sudo cp ${BACKUP_PATH} /vagrant/backup/${PHANTOM_VERSION}
fi

