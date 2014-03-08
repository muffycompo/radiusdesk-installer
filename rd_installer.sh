#!/bin/bash

# Define Utility variables
ARCH_TYPE=`arch`
OS_VERSION=`awk -F' ' '{ print $3 }' /etc/redhat-release`
CONF_DIR='conf/'
SOURCE_DIR='source/'
IP_ADDRESS=`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
 
# Color Guide
LIGHT_RED='\e[91m'
LIGHT_GREEN='\e[92m'
LIGHT_BLUE='\e[94m'
LIGHT_YELLOW='\e[93m'

# Formatting Options
BOLD='\e[1m'
F_END='\e[0m'

# Prompt for web server technology
read -p "What web server should we use? [N]ginx or [A]pache: " c
case "$c" in 
  n|N|nginx|Nginx ) 
	echo -e "Using ${LIGHT_BLUE}${BOLD}Nginx${F_END} Web server"
	webserver="nginx";;
  a|A|apache|Apache ) 
	echo -e "Using ${LIGHT_BLUE}${BOLD}Apache${F_END} Web server"
	webserver="httpd";;
  * ) 
	  echo "${LIGHT_RED}Oops...something went wrong, perharps you made a mistake in you selection?${F_END}"
	  exit 1;;
esac

########## KICKSTART & PACKAGES ##############

# Check if user is Root
echo -n "Checking if you are root: "
if [[ $EUID -ne 0 ]]; then
   echo -e "${LIGHT_RED}${BOLD}FAILED${F_END}" 1>&2
   exit 1
else
   echo -e "${LIGHT_GREEN}${BOLD}OK${F_END}"
fi

# Check if SELinux is disabled
echo -n "Checking if SELinux is enabled: "
if [[ "$(getenforce)" = "Enforcing" ]]; then
	setenforce 0
	sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	echo -e "${LIGHT_YELLOW}${BOLD}Corrected${F_END}"
else
	echo -e "${LIGHT_GREEN}${BOLD}Disabled${F_END}"
fi

# Flush iptable rules -> TODO: Revert to a more secure system
#echo -n "Flushing default Iptable rules: "
iptables -F
iptables -X 
service iptables save > /dev/null 2>&1

# Install some packages from base repo
echo -e "Installing ${LIGHT_BLUE}${BOLD}pre-requisite packages${F_END}\n"
yum install -y nano curl wget unzip > /dev/null 2>&1

# Install EPEL/POPTOP repo
echo -e "Installing ${LIGHT_BLUE}${BOLD}EPEL Repository${F_END}\n"
if [[ "$OS_VERSION" = "6.0" ]] || [[ "$OS_VERSION" = "6.1" ]] || [[ "$OS_VERSION" = "6.2" ]] || [[ "$OS_VERSION" = "6.3" ]] || [[ "$OS_VERSION" = "6.4" ]] || [[ "$OS_VERSION" = "6.5" ]]; then
	yum -q install -y http://dl.fedoraproject.org/pub/epel/6/${ARCH_TYPE}/epel-release-6-8.noarch.rpm > /dev/null 2>&1
	yum -q install -y http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm > /dev/null 2>&1
elif [[ "$OS_VERSION" = "5.2" ]] || [[ "$OS_VERSION" = "5.3" ]] || [[ "$OS_VERSION" = "5.4" ]] || [[ "$OS_VERSION" = "5.5" ]]; then
	yum -q install -y http://dl.fedoraproject.org/pub/epel/5/${ARCH_TYPE}/epel-release-5-4.noarch.rpm > /dev/null 2>&1
	yum -q install -y http://poptop.sourceforge.net/yum/stable/rhel5/pptp-release-current.noarch.rpm > /dev/null 2>&1
fi

# Install required packages
echo -e "Installing ${LIGHT_BLUE}${BOLD}required packages${F_END}\n"
yum -q install -y $webserver php php-fpm php-pear php-gd php-common php-cli php-mysql php-xcache \ 
mysql-server mysql subversion git vixie-cron mailx python perl perl-* unixODBC postgresql krb5 openldap libtool-ltdl \
gcc-c++ gcc make pptpd > /dev/null 2>&1

# Download & Install RHEL/CentOS 6 FreeRADIUS RPMs -> TODO: Compile RPMs for more OS_VERSIONs
if [[ "$ARCH_TYPE" = "x86_64" ]]; then
	wget -q -O /etc/yum.repos.d/maorepo-el6-x86_64.repo http://www.maomuffy.com/freeradius/repo/maorepo-el6-x86_64.repo
	yum --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap > /dev/null 2>&1
else
	wget -q -O /etc/yum.repos.d/maorepo-el6-i386.repo http://www.maomuffy.com/freeradius/repo/maorepo-el6-i386.repo
	yum --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap > /dev/null 2>&1
fi

########### RADIUSDESK REQUIREMENTS ###########

# Prepare Temp directory for downloaded files
mkdir -p /tmp/radiusdesk/
TEMP_PATH='/tmp/radiusdesk/'

# Download CakePHP 2.2.9 -> TODO: Find a way to make this version agnostic
echo -e "Downloading ${LIGHT_BLUE}${BOLD}CakePHP 2.2.9${F_END}\n"
wget -qL https://github.com/cakephp/cakephp/archive/2.2.9.zip -O ${TEMP_PATH}cakephp-2.2.9.zip

# Download Ext.Js 4.2.1
echo -e "Downloading ${LIGHT_BLUE}${BOLD}Ext.JS 4.2.1${F_END}\n"
wget -q http://sourceforge.net/p/radiusdesk/code/HEAD/tree/extjs/ext-4.2.1-gpl.zip?format=raw -O ${TEMP_PATH}ext-4.2.1-gpl.zip

# Download RadiusDESK Source
echo -e "Checking out ${LIGHT_BLUE}${BOLD}RadiusDESK source${F_END}\n"
svn --quiet checkout http://svn.code.sf.net/p/radiusdesk/code/trunk ${TEMP_PATH}source > /dev/null 2>&1

# Download NodeJS Source
echo -e "Downloading ${LIGHT_BLUE}${BOLD}NodeJS 0.10.26 source${F_END}\n"
wget -q http://nodejs.org/dist/v0.10.26/node-v0.10.26.tar.gz -O ${TEMP_PATH}node-v0.10.26.tar.gz
#npm -g install tail socket.io connect mysql forever > /dev/null 2>&1

########### RADIUSDESK COMPONENT INSTALLATION ###########

# Use web server to install to default location -> TODO: Might be useful to allow user input
if [[ "$webserver" = "nginx" ]]; then
	HTTP_DOCUMENT_ROOT='/usr/share/nginx/html/'
	
	# 1a) Nginx: php.ini
	cp -aR ${CONF_DIR}php.ini /etc/
	sed -i.bak 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini

	# 1b) Nginx: nginx.conf, default.conf
	cp -aR ${CONF_DIR}nginx/nginx.conf /etc/nginx/
	cp -aR ${CONF_DIR}nginx/default.conf /etc/nginx/conf.d/

	# 1c) php-fpm: www.conf
	cp -aR ${CONF_DIR}php-fpm/www.conf /etc/php-fpm.d/
	
	# Start services needed by RadiusDESK
	echo -e "Starting ${LIGHT_BLUE}${BOLD}services${F_END} needed by RadiusDESK\n"
	chkconfig php-fpm on
	service php-fpm start > /dev/null 2>&1
	service $webserver start > /dev/null 2>&1
	
elif [[ "$webserver" = "httpd" ]]; then
	HTTP_DOCUMENT_ROOT='/var/www/html/'
	
	# 1) Apache: httpd.conf
	cp -aR ${CONF_DIR}apache/httpd.conf /etc/httpd/conf/
	
	# Start services needed by RadiusDESK
	echo -e "Starting ${LIGHT_BLUE}${BOLD}services${F_END} needed by RadiusDESK\n"
	service $webserver start > /dev/null 2>&1
else
	echo -e "${LIGHT_RED}${BOLD}Something happened and we can not configure your system${F_END}\n"
	exit 1
fi

# Start services needed by RadiusDESK contd.
service mysqld start > /dev/null 2>&1

# Get to tmp directory where the action begins
cd ${TEMP_PATH}

# Install CakePHP
echo -e "Installing ${LIGHT_BLUE}${BOLD}CakePHP${F_END}\n"
unzip -q cakephp-2.2.9.zip
mv ${TEMP_PATH}cakephp-2.2.9 ${HTTP_DOCUMENT_ROOT}
ln -s ${HTTP_DOCUMENT_ROOT}cakephp-2.2.9 ${HTTP_DOCUMENT_ROOT}cake2

# Install rd_cake, rd2, meshdesk, rd_clients, rd_login_pages
echo -e "Installing ${LIGHT_BLUE}${BOLD}RadiusDESK${F_END}\n"
cp -aR ${SOURCE_DIR}rd_cake ${HTTP_DOCUMENT_ROOT}cake2/
cp -aR ${SOURCE_DIR}rd2 ${HTTP_DOCUMENT_ROOT}rd
cp -aR ${SOURCE_DIR}rd_login_pages ${HTTP_DOCUMENT_ROOT}rd_login_pages
cp -aR ${SOURCE_DIR}rd_clients ${HTTP_DOCUMENT_ROOT}rd_clients
cp -aR ${SOURCE_DIR}meshdesk ${HTTP_DOCUMENT_ROOT}meshdesk

echo -e "Installing ${LIGHT_BLUE}${BOLD}Ext.JS${F_END}\n"
unzip -q ext-4.2.1-gpl.zip
mv ext*/ ${HTTP_DOCUMENT_ROOT}rd/ext
cp -aR ${HTTP_DOCUMENT_ROOT}rd/ext/examples/ux ${HTTP_DOCUMENT_ROOT}rd/ext/src

# RadiusDESK cron script
cp -a ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Cron/rd /etc/cron.d/
sed -i 's|www-data|apache|g' /etc/cron.d/rd

# Make paths RHEL/CentOS compartible
echo -e "Correcting ${LIGHT_BLUE}${BOLD}files/directory paths${F_END} for compartibility\n"
if [[ "$webserver" = "nginx" ]]; then
	bash -c "grep -R --files-with-matches '/var/www' ${HTTP_DOCUMENT_ROOT}cake2 | sort | uniq | xargs perl -p -i.bak -e 's/\/var\/www/\/usr\/share\/nginx\/html/g'"
	sed -i 's|/var/www/cake2|/usr/share/nginx/html/cake2|g' /etc/cron.d/rd
elif [[ "$webserver" = "httpd" ]]; then
	bash -c "grep -R --files-with-matches '/var/www' ${HTTP_DOCUMENT_ROOT}cake2 | sort | uniq | xargs perl -p -i.bak -e 's/\/var\/www/\/var\/www\/html/g'"
	sed -i 's|/var/www/cake2|/var/www/html/cake2|g' /etc/cron.d/rd
fi

sed -i 's|/usr/local/share|/usr/share|g' ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Config/RadiusDesk.php
sed -i 's|/usr/local/etc/raddb|/etc/raddb|g' ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Config/RadiusDesk.php
sed -i 's|/usr/local/bin|/usr/bin|g' ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Config/RadiusDesk.php
sed -i "s|'id' => 'pptp',     'active' => false|'id' => 'pptp',     'active' => true|g" ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Config/RadiusDesk.php
sed -i 's|<script src="ext/ext-dev.js"></script>|<script src="ext/ext-all.js"></script>|g' ${HTTP_DOCUMENT_ROOT}rd/index.html
sed -i 's|Ext.Loader.setConfig({enabled:true});|Ext.Loader.setConfig({enabled:true,disableCaching: false});|g' ${HTTP_DOCUMENT_ROOT}rd/app/app.js 

# Import sql file to database
echo -e "Configuring ${LIGHT_BLUE}${BOLD}MySQL Database${F_END} for RadiusDESK\n"
mysql -u root -e "CREATE DATABASE rd;"
mysql -u root -e "GRANT ALL PRIVILEGES ON rd.* to 'rd'@'127.0.0.1' IDENTIFIED BY 'rd';"
mysql -u root -e "GRANT ALL PRIVILEGES ON rd.* to 'rd'@'localhost' IDENTIFIED BY 'rd';"
mysql -u root rd < ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Db/rd.sql 

# FreeRADIUS configuration
cp -aR ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Radius/checkrad /usr/sbin

mv /etc/raddb /etc/raddb.bak
tar xzf ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Radius/raddb_rd.tar.gz --directory=/etc/

sed -i 's|prefix = /usr/local|prefix = /usr|g' /etc/raddb/radiusd.conf
sed -i 's|sysconfdir = ${prefix}/etc|sysconfdir = /etc|g' /etc/raddb/radiusd.conf
sed -i 's|localstatedir = ${prefix}/var|localstatedir = /var|g' /etc/raddb/radiusd.conf

sed -i 's|#	sql2|	raw|g' /etc/raddb/radiusd.conf
sed -i 's|client localhost {|#client localhost {|g' /etc/raddb/clients.conf
sed -i 's|}|#}|g' /etc/raddb/clients.conf

sed -i 's|$prefix		= "/usr/local";|$prefix		= "/usr";|g' /usr/sbin/checkrad
sed -i 's|$localstatedir	= "${prefix}/var";|$localstatedir	= "/var";|g' /usr/sbin/checkrad
sed -i 's|$prefix		= "/usr/local";|$sysconfdir	= "/etc";|g' /usr/sbin/checkrad

sed -i 's|/usr/local/share/|/usr/share/|g' /etc/raddb/dictionary
sed -i 's|/usr/local/etc/|/etc/|g' /etc/raddb/dictionary

sed -i 's|"/usr/local/bin/radclient"|"/usr/bin/radclient"|g' ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Scripts/radscenario.pl

ln -s /etc/raddb/sites-available/dynamic-clients /etc/raddb/sites-enabled/dynamic-clients
cat ${OLDPWD}/utils/dynamic-clients > /etc/raddb/sites-enabled/dynamic-clients

cat > /etc/raddb/modules/raw <<EOF
raw { 
  
}
EOF

# Disabled TTY Requirements for Sudoers
sed -i 's|Defaults    requiretty|#Defaults    requiretty|g' /etc/sudoers
sed -i 's|Defaults   !visiblepw|#Defaults   !visiblepw|g' /etc/sudoers

# Add admin group to Sudoers
echo "%admin ALL=(ALL) ALL apache ALL = NOPASSWD:${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Scripts/radmin_wrapper.pl" >> /etc/sudoers

# Local IP for PPTP
echo "localip 10.20.30.1" >> /etc/pptpd.conf

# NodeJS Forever Init Script
cp -aR ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Node.js/nodejs-socket-io /etc/init.d

########### RADIUSDESK OWNERSHIP AND PERMISSIONS ###########

# Web Directory
chown -R apache:apache ${HTTP_DOCUMENT_ROOT}

# Radius Directory
chown -R radiusd:radiusd /etc/raddb

# Permissions
chmod 755 /usr/sbin/checkrad
chmod 644 /etc/raddb/dictionary
chmod -R 777 ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Scripts/*.pl
chmod 755 /etc/init.d/nodejs-socket-io

# NodeJS Installation
tar xzf node-v0.10.26.tar.gz
echo -e "Installing ${LIGHT_BLUE}${BOLD}NodeJS${F_END}\n"
cd node-v0*/
./configure > /dev/null 2>&1; make > /dev/null 2>&1 && make install > /dev/null 2>&1
npm -g install tail socket.io connect mysql forever > /dev/null 2>&1
cd ../

sed -i 's|NODE_BIN_DIR="/usr/bin"|NODE_BIN_DIR="/usr/local/bin"|g' /etc/init.d/nodejs-socket-io
sed -i 's|/usr/lib/node_modules|/usr/local/lib/node_modules|g' /etc/init.d/nodejs-socket-io
sed -i "s|/usr/share/nginx/www/html/|${HTTP_DOCUMENT_ROOT}|g" /etc/init.d/nodejs-socket-io

sed -i "s|/usr/local/var/|/var/|g" ${HTTP_DOCUMENT_ROOT}cake2/rd_cake/Setup/Node.js/Logfile.node.js 

# Make things start on boot
chkconfig --add nodejs-socket-io
chkconfig nodejs-socket-io on
chkconfig $webserver on
chkconfig radiusd on
chkconfig pptpd on

# Start/Restart services
echo -e "Checking if services are ${LIGHT_BLUE}${BOLD}fully Operational${F_END}\n"
service nodejs-socket-io start > /dev/null 2>&1
service $webserver restart > /dev/null 2>&1
service radiusd start > /dev/null 2>&1
service pptpd restart > /dev/null 2>&1

cd; rm -rf ${TEMP_PATH}

echo -e "\n\n"
echo -e "${LIGHT_GREEN}${BOLD}INSTALLATION COMPLETED SUCCESSFULLY!!!${F_END}\n"
echo -e "To access your RadiusDESK server, visit ${LIGHT_GREEN}${BOLD}http://${IP_ADDRESS}/rd${F_END}\n"
echo -e "USERNAME: ${LIGHT_YELLOW}${BOLD}root${F_END}  PASSWORD: ${LIGHT_YELLOW}${BOLD}admin${F_END}\n\n"
echo -e "We recommend ${LIGHT_RED}${BOLD}rebooting${F_END} you computer to ensure everything went as planned :)\n"

read -p "Do you want to reboot your computer now? [Y]es or [N]o: " answer
case "$answer" in 
  y|Y|yes|Yes ) 
	echo "${LIGHT_YELLOW}${BOLD}Rebooting...${F_END}"
	init 6;;
  n|N|no|No ) 
	echo "No biggy...we will do it another time :)";;
  * ) 
	exit 1;;
esac

# END