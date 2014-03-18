#!/bin/bash

# Description: Ubuntu/Debian Core Installer.
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

# Prompt for web server technology
OT=$(os_distro_type)
ask_for_webserver ${OT}


# Prompt for database customization
ask_for_database_customization


# Prompt for RADIUS customization
ask_for_radius_customization

########## KICKSTART & PACKAGES ##############
# Check if user is Root
echo ""
echo "============================================================="
echo -n "1. Checking if you are root: "
check_root_privileges

# Flush iptable rules -> TODO: Revert to a more secure system
echo ""
#echo -n "Flushing default Iptable rules: "
reset_iptables_rules

# Install some packages from base repo
echo "============================================================="
echo -e "2. Installing ${LIGHT_BLUE}${BOLD}pre-requisite packages${F_END}"
aptget_install nano curl wget unzip

# Install required packages
echo ""
echo "============================================================="
echo -e "3. Installing ${LIGHT_BLUE}${BOLD}required packages${F_END}"
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server mysql-server/root_password password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections
echo "postfix postfix/mailname string mail.maomuffy.com" | debconf-set-selections 
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
# Make changes to add additional repositories for NodeJS
aptget_install ${webserver} language-pack-en-base ${php_processor} php5-json mysql-server mysql-client php5-mysql php5-cli php5-gd php5-curl subversion php5-xcache git mailutils unixODBC perl postgresql gcc make pptpd libltdl7 python-software-properties python g++ make build-essential libmysqlclient-dev libperl-dev libssl-dev libpam0g-dev libgdbm-dev libldap2-dev libsasl2-dev unixODBC libkrb5-dev libperl-dev libpcap-dev python-dev snmp libsnmp-dev libpq-dev autotools-dev libtool dpatch dh-make devscripts
add-apt-repository -y ppa:chris-lea/node.js > /dev/null 2>&1
apt-get -qq update -y  > /dev/null 2>&1
aptget_install nodejs

########### RADIUSDESK REQUIREMENTS ###########

# Prepare Temp directory for downloaded files
mk_temp_dir

# Download CakePHP 2.2.9 -> TODO: Find a way to make this version agnostic
echo ""
echo "============================================================="
echo -e "4. Downloading ${LIGHT_BLUE}${BOLD}CakePHP 2.2.9${F_END}"
wget_download https://github.com/cakephp/cakephp/archive/2.2.9.zip ${TEMP_PATH}cakephp-2.2.9.zip

# Download Ext.Js 4.2.1
echo ""
echo "============================================================="
echo -e "5. Downloading ${LIGHT_BLUE}${BOLD}Ext.JS 4.2.1${F_END}"
wget_download http://sourceforge.net/p/radiusdesk/code/HEAD/tree/extjs/ext-4.2.1-gpl.zip?format=raw ${TEMP_PATH}ext-4.2.1-gpl.zip

# Download FreeRADIUS
echo ""
echo "============================================================="
echo -e "6. Downloading ${LIGHT_BLUE}${BOLD}FreeRADIUS 2.2.0${F_END}"
wget_download http://ftp.cc.uoc.gr/mirrors/ftp.freeradius.org/freeradius-server-2.2.0.tar.gz ${TEMP_PATH}freeradius-server-2.2.0.tar.gz

# Download RADIUSdesk Source
echo ""
echo "============================================================="
echo -e "7. Downloading ${LIGHT_BLUE}${BOLD}RADIUSdesk SVN sources${F_END}"
svn --quiet checkout http://svn.code.sf.net/p/radiusdesk/code/trunk ${TEMP_PATH}source > /dev/null 2>&1

########### RADIUSDESK COMPONENT INSTALLATION ###########

# Use web server to install to default location -> TODO: Might be useful to allow user input
if [[ "${webserver}" = "nginx" ]]; then
	
	# Document Root
	HTTP_DOCUMENT_ROOT='/usr/share/nginx/html/'
	
	# Copy nginx configuration files
	copy_ubuntu_nginx_configs ${CONF_DIR}
	
	# Start services needed by RADIUSdesk
	echo ""
	echo "============================================================="
	echo -e "8. Starting ${LIGHT_BLUE}${BOLD}services${F_END} needed by RADIUSdesk"
	echo /etc/init.d/php-fpm start >> /etc/rc.local
	restart_ubuntu_service php5-fpm
	restart_ubuntu_service ${webserver}
	
elif [[ "${webserver}" = "apache2" ]]; then
	HTTP_DOCUMENT_ROOT='/var/www/'
	
	# Copy apache configuration files
	copy_ubuntu_apache_configs ${CONF_DIR}
	
	# Start services needed by RADIUSdesk
	echo ""
	echo "============================================================="
	echo -e "8. Starting ${LIGHT_BLUE}${BOLD}services${F_END} needed by RADIUSdesk"
	restart_ubuntu_service ${webserver}
else
	echo ""
	echo "============================================================="
	echo -e "${LIGHT_RED}${BOLD}Something happened and we can not configure your system${F_END}"
	exit 1
fi

# Start services needed by RADIUSdesk contd.
#restart_ubuntu_service mysql

# Get to tmp directory where the action begins
get_to ${TEMP_PATH}

# Install CakePHP
echo ""
echo "============================================================="
echo -e "9. Installing ${LIGHT_BLUE}${BOLD}CakePHP${F_END}"
install_cakephp ${TEMP_PATH} ${HTTP_DOCUMENT_ROOT}

# Install rd_cake, rd2, meshdesk, rd_clients, rd_login_pages
echo ""
echo "============================================================="
echo -e "10. Installing ${LIGHT_BLUE}${BOLD}RADIUSdesk${F_END}"
install_radiusdesk ${TEMP_PATH} ${SOURCE_DIR} ${HTTP_DOCUMENT_ROOT}

echo ""
echo "============================================================="
echo -e "11. Installing ${LIGHT_BLUE}${BOLD}Ext.JS${F_END}"
install_extjs ${TEMP_PATH} ${HTTP_DOCUMENT_ROOT}

# RADIUSdesk cron script
echo ""
echo "============================================================="
echo -e "12. Installing ${LIGHT_BLUE}${BOLD}Cron Script${F_END} for RADIUSdesk"
install_radiusdesk_ubuntu_cron ${HTTP_DOCUMENT_ROOT}

echo ""
echo "============================================================="
echo -e "13. Updating ${LIGHT_BLUE}${BOLD}RADIUSdesk Paths${F_END} for Ubuntu/Debian compatibility"
update_radiusdesk_ubuntu_paths ${HTTP_DOCUMENT_ROOT}

# Customize FreeRADIUS
customize_freeradius ${HTTP_DOCUMENT_ROOT} ${rad_secret}

# FreeRADIUS configuration
configure_radiusdesk_ubuntu_freeradius ${HTTP_DOCUMENT_ROOT} ${RADIUS_UBUNTU_DIR} ${TEMP_PATH}

# Customize Database
customize_database ${HTTP_DOCUMENT_ROOT} ${db_host} ${db_user} ${db_password} ${db_name} ${RADIUS_UBUNTU_DIR}

# Import sql file to database
echo ""
echo "============================================================="
echo -e "14. Installing ${LIGHT_BLUE}${BOLD}Database Schema${F_END} for RADIUSdesk"
install_radiusdesk_schema ${HTTP_DOCUMENT_ROOT} ${db_name} ${db_user} ${db_password}

# Disabled TTY Requirements for Sudoers
fix_ubuntu_radiusdesk_sudoers ${SUDOERS_FILE} ${HTTP_DOCUMENT_ROOT}

########### RADIUSDESK OWNERSHIP AND PERMISSIONS ###########
# Update Ownership and Permissions
fix_radiusdesk_permissions_ownership_ubuntu ${HTTP_DOCUMENT_ROOT}

# NodeJS Installation
echo ""
echo "============================================================="
echo -e "15. Installing ${LIGHT_BLUE}${BOLD}NodeJS${F_END}"
install_ubuntu_nodejs ${HTTP_DOCUMENT_ROOT} /etc/init.d/

# Make things start on boot
start_ubuntu_service_on_boot ${webserver}
start_ubuntu_service_on_boot pptpd
start_ubuntu_service_on_boot mysql
start_ubuntu_service_on_boot php5-fpm

# Start/Restart services
echo ""
echo "============================================================="
echo -e "16. Checking if services are ${LIGHT_BLUE}${BOLD}fully Operational${F_END}"
restart_ubuntu_service nodejs-socket-io
restart_ubuntu_service ${webserver}
restart_ubuntu_service radiusd
restart_ubuntu_service pptpd
restart_ubuntu_service mysql
restart_ubuntu_service php5-fpm

# Clear temporary directory
clear_dir ${TEMP_PATH}

# RADIUSdesk Installation complete
echo ""
echo "==========================================================================="
echo -e "${LIGHT_GREEN}${BOLD}INSTALLATION COMPLETED SUCCESSFULLY!!!${F_END}"
echo ""
echo -e "To access your RADIUSdesk server, visit ${LIGHT_BLUE}${BOLD}http://${IP_ADDRESS}/rd${F_END} on your browser"
echo -e "USERNAME: ${LIGHT_BLUE}${BOLD}root${F_END}  PASSWORD: ${LIGHT_BLUE}${BOLD}admin${F_END}"
echo ""
echo -e "We recommend ${LIGHT_RED}${BOLD}rebooting${F_END} your computer to ensure everything went as planned :)"
echo "============================================================================"

# Prompt for CoovaChilli Installation
ask_for_coovachilli_install_ubuntu

# Prompt User to reboot
ask_for_reboot


# END