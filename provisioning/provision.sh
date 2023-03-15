#!/bin/bash

# Some variables to make the code cleaner
phantom_web_user="soar_local_admin"
phantom_web_password="password"
PHANTOM_HOME="/opt/phantom"

# Unprivileged setup
function run_unprivileged_setup () {
    # Create a temporary folder
    mkdir -p /tmp/splunk-soar && cd /tmp/splunk-soar

    # TODO: At worst, this could return more files, handle it
    PHANTOM_ARCHIVE=$( find /vagrant/install/ -name "splunk_soar-unpriv-${PHANTOM_VERSION}*.tgz" )

    echo "[*] Archive found: ${PHANTOM_ARCHIVE}"

    # Untar
    echo "[*] Untar installation files to the /tmp location"
    tar xf ${PHANTOM_ARCHIVE} --directory /tmp/splunk-soar

    # Pre-5.3.x setup
    ### setup system limits
    # /tmp/splunk-soar/phantom_tar_install.sh install --https-port=8443 --no-space-check

    # 5.3.x setup
    # Run the pre-installation steps, no-prompt mode
    INSTALL_FILE=soar-prepare-system
    install_file_path=$(find /tmp/splunk-soar/ -name ${INSTALL_FILE})
    INSTALL_SOURCE_DIR=$(dirname "${install_file_path}")
    sudo "${install_file_path}" --splunk-soar-home ${PHANTOM_HOME} -v --no-prompt

    # This feels a bit like a hack, but it works...
    sudo chown -R phantom:phantom /tmp/splunk-soar/

    # The previous step created a 'phantom' user, let's use it
    # Now, it installed all the things it needed, time to run the unprivileged setup
    # TODO: Consider adding --with-apps
    sudo -u phantom -g phantom ${INSTALL_SOURCE_DIR}/soar-install --splunk-soar-home ${PHANTOM_HOME} -v --no-prompt --ignore-warnings
}

# Handle the Phantom version
# SOAR versions in .tgz files
soar_versions=( $( find /vagrant/install -iname \*.tgz -maxdepth 1 -mindepth 1 -type f -exec basename {} \; | sed 's/splunk_soar-unpriv-\([0-9\.]\{4,\}\)-.*\.tgz/\1/' | sort -nr ) )
combined=( "${soar_versions[@]}" )

# Is any specific version requested?
if [ -n "${PHANTOM_VERSION}" ]; then
   echo "Vagrant enforced Phantom/SOAR version: ${PHANTOM_VERSION}"
else
   # If not, set the latest available Phantom version
   # TODO: There may be none, check the array size first
   PHANTOM_VERSION=${combined[0]}
fi

echo "[*] Phantom version to be installed: ${PHANTOM_VERSION}"

if [[ " ${combined[*]} " == *" ${PHANTOM_VERSION} "* ]]; then
    echo "[*] All good, requested Phantom version (${PHANTOM_VERSION}) present in the cache."
else
    echo "[!] Requested Phantom version isn't available in the cache."
    echo "[!] Available versions:"
    for i in "${combined[@]}"; do
       echo "[!]    ${i[@]}"
    done
    exit 
    # TODO: A fallback that would ask for credentials and download it, perhaps?
fi

# Fix /etc/locale.conf. No idea why it's broken, but it's better to fix it
sudo cp -v /vagrant/provisioning/locale.conf /etc/

privileged=0
run_unprivileged_setup

#####
# Custom Configuration

# Be ready for a backup restoration procedure
# TODO: Backups could be version-specific, handle it.
#       Also, this is for privileged setup, unprivilged needs to be handled differently
echo "[*] Preparation for any backup operations"
if [ "${privileged}" -eq 1 ]; then
   sudowrapper="sudo"
else
   sudowrapper="sudo -u phantom -g phantom"
fi

cd /opt/phantom # Due to sudo permissions requirements
${sudowrapper} /opt/phantom/bin/phenv ibackup --setup --no-prompt
# Find the latest backup in the /vagrants/backup/
latest_backup=$(find /vagrant/backup/${PHANTOM_VERSION} -name \*.tgz -print0 2>/dev/null | xargs -r -0 ls -1 -t | head -1)
if [ -n "${latest_backup}" ] && [ -s "${latest_backup}" ]; then
   echo "[*] Restoring backup: ${latest_backup}"
   ${sudowrapper} /opt/phantom/bin/phenv ibackup --restore "${latest_backup}" --no-prompt
else
   echo "[*] No suitable backup found, skipping the restore part"
fi

####
# Final Stage
# Announce the URL where Splunk is available now
echo "**********************************************************************************"
echo " Congratulations! Your Splunk Phantom instance is running at:"
echo "     unprivileged: https://localhost:9998/"
echo " Authenticate with ${phantom_web_user}:${phantom_web_password} (username:password)"
echo "**********************************************************************************"

