#!/bin/bash

# Description: CoovaChilli Core Installer.
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
echo ""
echo "============================================================="
echo -n "1. Checking if you are root: "
check_root_privileges

# Check if SELinux is disabled
echo ""
echo "============================================================="
echo -n "2. Checking if SELinux is enabled: "
check_selinux_status

echo ""
#echo -n "Flushing default Iptable rules: "
reset_iptables_rules

# Install some packages from base repo
echo "============================================================="
echo -e "3. Installing ${LIGHT_BLUE}${BOLD}pre-requisite packages${F_END}"
yum_install nano curl wget unzip
 
# Install EPEL/POPTOP repo
echo ""
echo "============================================================="
echo -e "4. Installing ${LIGHT_BLUE}${BOLD}EPEL Repository${F_END}"
install_epel_repo ${OS_VERSION} ${ARCH_TYPE}

# Download & Install RHEL/CentOS 6 FreeRADIUS RPMs -> TODO: Compile RPMs for more OS_VERSIONS
install_mao_repo ${ARCH_TYPE}

# Install CoovaChilli 1.3.0 from maorepo
echo ""
echo "============================================================="
echo -e "5. Installing ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
yum_install coova-chilli vixie-cron

#configure CoovaChilli
configure_coovachilli ${COOVACHILLI_DIR} ${wan_if} ${lan_if} ${lan_net} ${lan_sm} ${radius_secret} ${uam_secret}

# Start CoovaChilli on Boot
start_service_on_boot chilli


# Start CoovaChilli
restart_service chilli


# CoovaChilli Installation complete
echo
echo "================================================================================="
echo -e "${LIGHT_GREEN}${BOLD}INSTALLATION COMPLETED SUCCESSFULLY!!!${F_END}"
echo
echo -e "Connect your clients to ${lan_if} and see your Captive Portal  hotspot in action!"
echo 
echo -e "We recommend ${LIGHT_RED}${BOLD}rebooting${F_END} your computer to ensure everything went as planned :)"
echo "================================================================================="

# Prompt User to reboot
ask_for_reboot
# END