#!/bin/bash

# Description: CoovaChilli Core Ubuntu Installer.
# Author: Mfawa Alfred Onen
# Link/URL: http://muffycompo.github.io/radiusdesk-installer
# Date: March 14, 2014

# Ensure variables, functions and prompts exist
if [[ ! -e "includes/variables.sh" ]] || [[ ! -e "includes/functions.sh" ]] || [[ ! -e "includes/prompts.sh" ]]; then
	echo "=================================================================================================="
	echo "We can not start the installer because some files are missing, try re-downloading the installer!"
	echo "=================================================================================================="
	exit 1
else
	source includes/variables.sh
	source includes/functions.sh
	source includes/prompts.sh
fi

# Ensure we have two network cards NICs
if [[ ${IF_COUNT} -lt 2 ]]; then
	echo "============================================================"
	echo -e "${LIGHT_RED}${BOLD}You MUST have atleast two network interface cards (NICs)!${F_END}"
	echo "============================================================"
	exit 1
fi

# Prompt for coovachilli customization
ask_for_coovachilli_customization

# Check if user is Root
echo
echo "============================================================="
echo -n "1. Checking if you are root: "
check_root_privileges

echo
#echo -n "Flushing default Iptable rules: "
reset_iptables_rules

# Install some packages from base repo
echo "============================================================="
echo -e "2. Installing ${LIGHT_BLUE}${BOLD}pre-requisite packages${F_END}"
aptget_install nano curl wget unzip

# Install CoovaChilli 1.3.0
echo
echo "============================================================="
echo -e "3. Installing ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
if [[ "$(arch)" = "x86_64" ]]; then
	wget_download http://maomuffy.com/repo/ubuntu/coovachilli/x86_64/coova-chilli_1.3.0_amd64.deb coova-chilli_1.3.0.deb
else
	wget_download http://ap.coova.org/chilli/coova-chilli_1.3.0_i386.deb coova-chilli_1.3.0.deb
fi
dpkg -i coova-chilli*.deb > /dev/null 2>&
rm -rf coova-chilli*.deb

#configure CoovaChilli
echo
echo "============================================================="
echo -e "4. Configuring ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
configure_coovachilli ${COOVACHILLI_DIR} ${wan_if} ${lan_if} ${lan_net} ${lan_sm} ${radius_secret} ${uam_secret} ${radiusdesk_ip}

# Enable Chilli
sed -i 's|START_CHILLI=0|START_CHILLI=1|g' /etc/default/chilli

# Start CoovaChilli on Boot
start_ubuntu_service_on_boot chilli

# Start CoovaChilli
start_ubuntu_service chilli


# CoovaChilli Installation complete
echo
echo "======================================================================================="
echo -e "${LIGHT_GREEN}${BOLD}INSTALLATION COMPLETED SUCCESSFULLY!!!${F_END}"
echo
echo -e "Connect your clients to ${lan_if} and see your Captive Portal in action!"
echo 
echo -e "We recommend ${LIGHT_RED}${BOLD}rebooting${F_END} your computer to ensure everything went as planned :)"
echo "======================================================================================="

# Prompt User to reboot
ask_for_reboot
# END