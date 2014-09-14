#!/bin/bash

########## Start Functions #########

# Check for root user privileges
function check_root_privileges(){
	if [[ ${1} -ne 0 ]]; then
	   echo -e "${LIGHT_RED}${BOLD}FAILED${F_END}" 1>&2
	   exit 1
	else
	   echo -e "${LIGHT_GREEN}${BOLD}OK${F_END}"
	fi
}

# Check SELinux status
function check_selinux_status(){
	if [[ "$(getenforce)" = "Enforcing" ]]; then
		setenforce 0
		sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
		echo -e "${LIGHT_RED}${BOLD}Corrected${F_END}"
	else
		echo -e "${LIGHT_GREEN}${BOLD}Disabled${F_END}"
	fi
}

# Check AppArmor status
function check_apparmor_status(){
	if [[ -f "/etc/init.d/apparmor" ]]; then
		/etc/init.d/apparmor stop > /dev/null 2>&1
		/etc/init.d/apparmor teardown > /dev/null 2>&1
		update-rc.d -f apparmor remove > /dev/null 2>&1
		echo -e "${LIGHT_RED}${BOLD}Corrected${F_END}"
	else
		echo -e "${LIGHT_GREEN}${BOLD}Disabled${F_END}"
	fi
}

# Reset IPTables
function reset_iptables_rules(){
	iptables -F
	iptables -X 
	service iptables save > /dev/null 2>&1
}

# YUM Installer
function yum_install(){
	yum -q install -y ${@} > /dev/null 2>&1
}

# APT-GET Installer
function aptget_install(){
	apt-get -qq -y install ${@} > /dev/null 2>&1
}

# EPEL/POPTOP REPO
function install_epel_repo(){
	if [[ ${1} -eq 6 ]]; then
		rpm -Uh --quiet http://dl.fedoraproject.org/pub/epel/${1}/${2}/epel-release-6-8.noarch.rpm > /dev/null 2>&1
		rpm -Uh --quiet http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm > /dev/null 2>&1
	elif [[ ${1} -eq 5 ]]; then
		rpm -Uh --quiet http://dl.fedoraproject.org/pub/epel/${1}/${2}/epel-release-5-4.noarch.rpm > /dev/null 2>&1
		rpm -Uh --quiet http://poptop.sourceforge.net/yum/stable/rhel5/pptp-release-current.noarch.rpm > /dev/null 2>&1
	fi
}

# MAO FreeRADIUS REPO -> Compiled with RLM_RAW support for Dynamic clients
function install_mao_repo(){
	if [[ "$1" = "x86_64" ]]; then
		wget -q -O /etc/yum.repos.d/maorepo-el6-x86_64.repo http://www.maomuffy.com/freeradius/repo/maorepo-el6-x86_64.repo
		yum -q --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap freeradius-utils > /dev/null 2>&1
	else
		wget -q -O /etc/yum.repos.d/maorepo-el6-i386.repo http://www.maomuffy.com/freeradius/repo/maorepo-el6-i386.repo
		yum -q --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap freeradius-utils > /dev/null 2>&1
	fi
}

# wget Downloader
function wget_download(){
	wget -qL ${1} -O ${2}
}

# Start Service
function start_service(){
	service ${1} start > /dev/null 2>&1
}

# Start Ubuntu Service
function start_ubuntu_service(){
	/etc/init.d/${1} start > /dev/null 2>&1
}

# Restart Service
function restart_service(){
	service ${1} restart > /dev/null 2>&1
}

# Restart Ubuntu Service
function restart_ubuntu_service(){
	/etc/init.d/${1} restart > /dev/null 2>&1
}

# Stop Service
function stop_ubuntu_service(){
	/etc/init.d/${1} stop > /dev/null 2>&1
}

# Stop Service
function stop_service(){
	service ${1} stop > /dev/null 2>&1
}

# Start Service on Boot
function start_service_on_boot(){
	chkconfig ${1} on
}

# Start Ubuntu Service on Boot
function start_ubuntu_service_on_boot(){
	#echo "/etc/init.d/${1} start" >> /etc/rc.local
	update-rc.d ${1} defaults > /dev/null 2>&1
}

# Copy Nginx Config
function copy_nginx_configs(){
	# 1a) Nginx: php.ini
	cp -aR ${1}php.ini /etc/
	sed -i.bak 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini

	# 1b) Nginx: nginx.conf, default.conf
	cp -aR ${1}nginx/nginx.conf /etc/nginx/
	cp -aR ${1}nginx/default.conf /etc/nginx/conf.d/

	# 1c) php-fpm: www.conf
	cp -aR ${1}php-fpm/www.conf /etc/php-fpm.d/
}

# Copy Ubuntu Nginx Config
function copy_ubuntu_nginx_configs(){
	# 1a) Nginx: php.ini
	cp -aR ${1}ubuntu_php.ini /etc/php5/fpm/php.ini
	cp -aR ${1}ubuntu_php.ini /etc/php5/cli/php.ini
	sed -i.bak 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php5/cli/php.ini

	# 1b) Nginx: nginx.conf, default.conf
	cp -aR ${1}nginx/ubuntu_nginx.conf /etc/nginx/nginx.conf
	cp -aR ${1}nginx/ubuntu_default.conf /etc/nginx/sites-available/default

	# 1c) php-fpm: www.conf
	cp -aR ${1}php-fpm/ubuntu_www.conf /etc/php5/fpm/pool.d/www.conf
}

# Copy Apache Config
function copy_apache_configs(){
	# 1) Apache: httpd.conf
	cp -aR ${1}php.ini /etc/
	cp -aR ${1}apache/httpd.conf /etc/httpd/conf/
}

# Copy Ubuntu Apache Config
function copy_ubuntu_apache_configs(){
	# 1) Apache: httpd.conf
	cp -aR ${1}ubuntu_php.ini /etc/php5/cli/php.ini
	cp -aR ${1}ubuntu_php.ini /etc/php5/apache2/php.ini
	cp -aR ${1}apache/apache2.conf /etc/apache2/apache2.conf
	# Enable RADIUSdesk required modules
	a2enmod rewrite > /dev/null 2>&1
	a2enmod deflate > /dev/null 2>&1
	a2enmod headers > /dev/null 2>&1
}

# cd to directory
function get_to(){
	cd ${1}
}

# Install CakePHP
function install_cakephp(){
	get_to ${1}
	unzip -q cakephp-2.2.9.zip
	mv ${1}cakephp-2.2.9 ${2}
	ln -s ${2}cakephp-2.2.9 ${2}cake2
}

# Install Ext.JS
function install_extjs(){
	get_to ${1}
	unzip -q ext-4.2.1-gpl.zip
	mv ext*/ ${2}rd/ext
	cp -aR ${2}rd/ext/examples/ux ${2}rd/ext/src
}

# Install NodeJS
function install_nodejs(){
	get_to ${1}
	tar xzf node-v0.10.26.tar.gz
	cd node-v0*/
	# Configure and install Node.JS
	./configure > /dev/null 2>&1; make > /dev/null 2>&1 && make install > /dev/null 2>&1
	npm -g install tail socket.io@0.9.17 connect mysql forever > /dev/null 2>&1
	cd ../
	# Fix Paths for RHEL/CentOS compatibility
	sed -i 's|NODE_BIN_DIR="/usr/bin"|NODE_BIN_DIR="/usr/local/bin"|g' ${3}nodejs-socket-io
	sed -i 's|/usr/lib/node_modules|/usr/local/lib/node_modules|g' ${3}nodejs-socket-io
	sed -i "s|/usr/share/nginx/www/html/|${2}|g" ${3}nodejs-socket-io
	sed -i "s|/usr/share/nginx/www/cake2|${2}cake2|g" ${3}nodejs-socket-io
	sed -i "s|/var/www/cake2|${2}cake2|g" ${3}nodejs-socket-io
	sed -i "s|/usr/local/var/|/var/|g" ${2}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	# Add to chkconfig
	chkconfig --add nodejs-socket-io
}

# Install Ubuntu NodeJS
function install_ubuntu_nodejs(){
	npm -g install tail socket.io@0.9.17 connect mysql forever > /dev/null 2>&1

	# Fix Paths for Ubuntu compatibility
	sed -i "s|/usr/share/nginx/www/html/|${1}|g" ${2}nodejs-socket-io
	sed -i "s|/usr/share/nginx/www/cake2|${1}cake2|g" ${2}nodejs-socket-io
	sed -i "s|/var/www/cake2|${1}cake2|g" ${2}nodejs-socket-io
	# Add to Startup
	update-rc.d nodejs-socket-io start 80 2 3 4 5 . stop 20 0 1 6 .  > /dev/null 2>&1
}

# Install RADIUSdesk
function install_radiusdesk(){
	get_to ${1}
	cp -aR ${2}rd_cake ${3}cake2/
	cp -aR ${2}rd ${3}rd
	cp -aR ${2}rd_login_pages ${3}rd_login_pages
	cp -aR ${2}rd_clients ${3}rd_clients
	cp -aR ${2}meshdesk ${3}meshdesk
	# NodeJS Forever Init Script
	cp -aR ${3}cake2/rd_cake/Setup/Node.js/nodejs-socket-io /etc/init.d
}

# Install RADIUSdesk CRON
function install_radiusdesk_cron(){
	cp -a ${1}cake2/rd_cake/Setup/Cron/rd /etc/cron.d/
	sed -i 's|www-data|apache|g' /etc/cron.d/rd
	
	if [[ "${2}" = "nginx" ]]; then
		bash -c "grep -R --files-with-matches '/var/www' ${1}cake2 | sort | uniq | xargs perl -p -i.bak -e 's/\/var\/www/\/usr\/share\/nginx\/html/g'"
		sed -i 's|/var/www/cake2|/usr/share/nginx/html/cake2|g' /etc/cron.d/rd
	elif [[ "${2}" = "httpd" ]]; then
		bash -c "grep -R --files-with-matches '/var/www' ${1}cake2 | sort | uniq | xargs perl -p -i.bak -e 's/\/var\/www/\/var\/www\/html/g'"
		sed -i 's|/var/www/cake2|/var/www/html/cake2|g' /etc/cron.d/rd
	fi
}

# Install RADIUSdesk Ubuntu CRON
function install_radiusdesk_ubuntu_cron(){
	cp -a ${1}cake2/rd_cake/Setup/Cron/rd /etc/cron.d/
	
	bash -c "grep -R --files-with-matches '/var/www' ${1}cake2 | sort | uniq | xargs sed -i 's|/var/www/|${1}|g'"
	sed -i "s|/var/www/cake2|${1}cake2|g" /etc/cron.d/rd
}

# Update RADIUSdesk Paths
function update_radiusdesk_paths(){
	sed -i 's|/usr/local/share|/usr/share|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|/usr/local/etc/raddb|/etc/raddb|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|/usr/local/bin|/usr/bin|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i "s|'id' => 'pptp',     'active' => false|'id' => 'pptp',     'active' => true|g" ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|<script src="ext/ext-dev.js"></script>|<script src="ext/ext-all.js"></script>|g' ${1}rd/index.html
	sed -i 's|Ext.Loader.setConfig({enabled:true});|Ext.Loader.setConfig({enabled:true,disableCaching: false});|g' ${1}rd/app.js 
}

# Update RADIUSdesk Ubuntu Paths
function update_radiusdesk_ubuntu_paths(){
	sed -i "s|'id' => 'pptp',     'active' => false|'id' => 'pptp',     'active' => true|g" ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|<script src="ext/ext-dev.js"></script>|<script src="ext/ext-all.js"></script>|g' ${1}rd/index.html
	sed -i 's|Ext.Loader.setConfig({enabled:true});|Ext.Loader.setConfig({enabled:true,disableCaching: false});|g' ${1}rd/app.js 
}

# Install RADIUSdesk MySQL Schema
function install_radiusdesk_schema(){
	mysql -u root -e "CREATE DATABASE ${2};" > /dev/null 2>&1
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${2}.* to '${3}'@'127.0.0.1' IDENTIFIED BY '${4}';" > /dev/null 2>&1
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${2}.* to '${3}'@'localhost' IDENTIFIED BY '${4}';" > /dev/null 2>&1
	mysql -u root ${2} < ${1}cake2/rd_cake/Setup/Db/rd.sql > /dev/null 2>&1
}

# Configure FreeRADIUS
function configure_radiusdesk_freeradius(){
	# Replace existing checkrad with RADIUSdesk modified version
	cp -aR ${1}cake2/rd_cake/Setup/Radius/checkrad /usr/sbin

	# Backup original raddb directory
	mv ${2} /etc/raddb.bak
	tar xzf ${1}cake2/rd_cake/Setup/Radius/raddb_rd.tar.gz --directory=/etc/

	# Fix Variables & Paths for RHEL/CentOS compatibility
	sed -i 's|prefix = /usr/local|prefix = /usr|g' ${2}radiusd.conf
	sed -i 's|sysconfdir = ${prefix}/etc|sysconfdir = /etc|g' ${2}radiusd.conf
	sed -i 's|localstatedir = ${prefix}/var|localstatedir = /var|g' ${2}radiusd.conf
	sed -i 's|#	sql2|	raw|g' ${2}radiusd.conf
	sed -i 's|client localhost {|#client localhost {|g' ${2}clients.conf
	sed -i 's|}|#}|g' ${2}clients.conf
	sed -i 's|$prefix		= "/usr/local";|$prefix		= "/usr";|g' /usr/sbin/checkrad
	sed -i 's|$localstatedir	= "${prefix}/var";|$localstatedir	= "/var";|g' /usr/sbin/checkrad
	sed -i 's|$prefix		= "/usr/local";|$sysconfdir	= "/etc";|g' /usr/sbin/checkrad
	sed -i 's|/usr/local/share/|/usr/share/|g' ${2}dictionary
	sed -i 's|/usr/local/etc/|/etc/|g' ${2}dictionary
	sed -i 's|"/usr/local/bin/radclient"|"/usr/bin/radclient"|g' ${1}cake2/rd_cake/Setup/Scripts/radscenario.pl

	ln -s ${2}sites-available/dynamic-clients ${2}sites-enabled/dynamic-clients
	cp -aR ${3}dynamic-clients ${2}sites-enabled/dynamic-clients

cat > ${2}modules/raw <<EOF
raw { 
  
}
EOF

	# Local IP for PPTP
	echo "localip 10.20.30.1" >> /etc/pptpd.conf

}


# Configure FreeRADIUS
function configure_radiusdesk_ubuntu_freeradius(){
	# Patch 
	# patch -p1 < ../source/rd_cake/Setup/Radius/rlm_raw_patch
	get_to ${3}
	tar xzf freeradius-server-2.2.0.tar.gz
	cd freeradius-server*/
	patch -p1 < ${1}cake2/rd_cake/Setup/Radius/rlm_raw_patch > /dev/null 2>&1
	echo "rlm_raw" >> src/modules/stable
	 
	# Configure and install FreeRADIUS
	./configure > /dev/null 2>&1; make -i > /dev/null 2>&1; make -i install > /dev/null 2>&1; ldconfig > /dev/null 2>&1
	cd ../
	
	cp -aR /usr/local/sbin/rc.radiusd /etc/init.d/radiusd
	update-rc.d radiusd start 80 2 3 4 5 . stop 20 0 1 6 .  > /dev/null 2>&1
	
	# Replace existing checkrad with RADIUSdesk modified version
	cp -aR ${1}cake2/rd_cake/Setup/Radius/checkrad /usr/local/sbin

	# Backup original raddb directory
	mv ${2} /usr/local/etc/raddb.bak
	tar xzf ${1}cake2/rd_cake/Setup/Radius/raddb_rd.tar.gz --directory=/usr/local/etc/

	sed -i 's|#	sql2|	raw|g' ${2}radiusd.conf
	sed -i 's|client localhost {|#client localhost {|g' ${2}clients.conf
	sed -i 's|}|#}|g' ${2}clients.conf

	ln -s ${2}sites-available/dynamic-clients ${2}sites-enabled/dynamic-clients
	cp -aR ${3}dynamic-clients ${2}sites-enabled/dynamic-clients

cat > ${2}modules/raw <<EOF
raw { 
  
}
EOF

	# Local IP for PPTP
	echo "localip 10.20.30.1" >> /etc/pptpd.conf

}

# Fix sudoers file for RADIUSdesk
function fix_radiusdesk_sudoers(){
	sed -i 's|Defaults    requiretty|#Defaults    requiretty|g' ${1}
	sed -i 's|Defaults   !visiblepw|#Defaults   !visiblepw|g' ${1}
	# Add admin group to Sudoers
	echo "%admin ALL=(ALL) ALL apache ALL = NOPASSWD:${2}cake2/rd_cake/Setup/Scripts/radmin_wrapper.pl" >> ${1}
	echo "apache ALL = NOPASSWD:${2}cake2/rd_cake/Setup/Scripts/radmin_wrapper.pl" >> ${1}

}

# Fix Ubuntu sudoers file for RADIUSdesk
function fix_ubuntu_radiusdesk_sudoers(){
	# Add admin group to Sudoers
	echo "%admin ALL=(ALL) ALL www-data ALL = NOPASSWD:${2}cake2/rd_cake/Setup/Scripts/radmin_wrapper.pl" >> ${1}
	echo "www-data ALL = NOPASSWD:${2}cake2/rd_cake/Setup/Scripts/radmin_wrapper.pl" >> ${1}

}

# Fix RADIUSdesk permissions and ownership
function fix_radiusdesk_permissions_ownership(){
	# Web Directory -> both nginx and httpd use apache user
	chown -R apache:apache ${1}

	# Radius Directory
	chown -R radiusd:radiusd /etc/raddb

	# Permissions
	chmod 755 /usr/sbin/checkrad
	chmod 644 /etc/raddb/dictionary
	chmod -R 777 ${1}cake2/rd_cake/Setup/Scripts/*.pl
	chmod 755 /etc/init.d/nodejs-socket-io
}

# Fix RADIUSdesk permissions and ownership for Ubuntu
function fix_radiusdesk_permissions_ownership_ubuntu(){
	# Web Directory -> both nginx and httpd use apache user
	chown -R www-data:www-data ${1}

	# Radius Directory
	# chown -R radiusd:radiusd /usr/local/etc/raddb

	# Permissions
	chmod 755 /usr/local/sbin/checkrad
	chmod 644 /usr/local/etc/raddb/dictionary
	chmod -R 777 ${1}cake2/rd_cake/Setup/Scripts/*.pl
	chmod 755 /etc/init.d/nodejs-socket-io
}

# Create Temporary Directory
function mk_temp_dir(){
	mkdir -p /tmp/radiusdesk/
	# Temporary fix
	cp -aR utils/dynamic-clients /tmp/radiusdesk/
}

# Customize FreeRadius
function customize_freeradius(){
	sed -i "s|testing123|${2}|g" ${1}cake2/rd_cake/Setup/Scripts/radscenario.pl
	sed -i "s|testing123|${2}|g" ${1}cake2/rd_cake/Setup/Db/rd.sql
}

# Customize MySQL Database
function customize_database(){	
	#Logfile.node.js
	sed -i "s|host     : 'localhost'|host     : '${2}'|g" ${1}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	sed -i "s|user     : 'rd'|user     : '${3}'|g" ${1}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	sed -i "s|password : 'rd'|password : '${4}'|g" ${1}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	sed -i "s|database : 'rd'|database : '${5}'|g" ${1}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	
	#sql.conf
	sed -i "s|server = \"localhost\"|server = \"${2}\"|g" ${6}sql.conf
	sed -i "s|login = \"rd\"|login = \"${3}\"|g" ${6}sql.conf
	sed -i "s|password = \"rd\"|password = \"${4}\"|g" ${6}sql.conf
	sed -i "s|radius_db = \"rd\"|radius_db = \"${5}\"|g" ${6}sql.conf
	
	#SQLConnector.pm
	sed -i "s|my \$db_server   = '127.0.0.1'|my \$db_server   = '${2}'|g" ${6}rlm_perl_modules/SQLConnector.pm
	sed -i "s|my \$db_user     = 'rd'|my \$db_user     = '${3}'|g" ${6}rlm_perl_modules/SQLConnector.pm
	sed -i "s|my \$db_password = 'rd'|my \$db_password = '${4}'|g" ${6}rlm_perl_modules/SQLConnector.pm
	sed -i "s|my \$db_name     = 'rd'|my \$db_name     = '${5}'|g" ${6}rlm_perl_modules/SQLConnector.pm
	
	#database.php
	sed -i "s|'host' => 'localhost'|'host' => '${2}'|g" ${1}cake2/rd_cake/Config/database.php
	sed -i "s|'login' => 'rd'|'login' => '${3}'|g" ${1}cake2/rd_cake/Config/database.php
	sed -i "s|'password' => 'rd'|'password' => '${4}'|g" ${1}cake2/rd_cake/Config/database.php
	sed -i "s|'database' => 'rd'|'database' => '${5}'|g" ${1}cake2/rd_cake/Config/database.php
}

function configure_coovachilli(){
TRIM_UAM_IP="`echo "${4}" | awk -F'.' '{ print $1"."$2"."$3 }'`.1"
cat > ${1}config <<EOF
HS_WANIF=${2}
HS_LANIF=${3}
HS_NETWORK=${4}
HS_NETMASK=${5}
HS_UAMLISTEN=${TRIM_UAM_IP}
HS_UAMPORT=3990
HS_UAMUIPORT=4990
HS_DNS_DOMAIN=maomuffy.com
HS_DNS1=208.67.222.222
HS_DNS2=208.67.220.220
HS_UAMALLOW=www.maomuffy.com
HS_RADIUS=${8}
HS_RADIUS2=${8}
HS_RADSECRET=${6}
HS_UAMSECRET=${7}
HS_UAMALIASNAME=chilli
HS_NASIP=${8}

HS_NASID=rd_nas
HS_SSID="Struisbaai"
HS_UAMSERVER=${TRIM_UAM_IP}
HS_UAMFORMAT=http://${TRIM_UAM_IP}/cake2/rd_cake/dynamic_details/chilli_browser_detect/

HS_MACAUTH=on
HS_ANYIP=on
HS_TCP_PORTS="22 80 8000 53 1812 67 443"
HS_MODE=hotspot
HS_TYPE=chillispot
# HS_POSTAUTH_PROXY=<host or ip>
# HS_POSTAUTH_PROXYPORT=<port>
HS_WWWDIR=/etc/chilli/www
HS_WWWBIN=/etc/chilli/wwwsh
HS_PROVIDER=RADIUSdesk
HS_PROVIDER_LINK=http://www.maomuffy.com
HS_LOC_NAME="RADIUSdesk Hotspot"
HS_LOC_NETWORK="RADIUSdesk_Network"
HS_LOC_AC=234 
HS_LOC_CC=1
HS_LOC_ISOCC=NG
HS_COAPORT=3799
EOF

# # Add NAT rules - MASQUERADING
# iptables -F POSTROUTING -t nat
# iptables -I POSTROUTING -t nat -o ${2} -j MASQUERADE
# iptables-save > /dev/null 2>&1
sed -i '/ifconfig $HS_LANIF 0.0.0.0/c \
#NAT mod \
iptables -F POSTROUTING -t nat \
iptables -I POSTROUTING -t nat -o $HS_WANIF -j MASQUERADE \
#END NAT mod \
\
ifconfig $HS_LANIF 0.0.0.0' /etc/init.d/chilli

# Enable IP FORWARDING
sed -i 's|net.ipv4.ip_forward = 0|net.ipv4.ip_forward = 1|g' /etc/sysctl.conf
# commented in Ubuntu
sed -i 's|#net.ipv4.ip_forward = 1|net.ipv4.ip_forward = 1|g' /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

# Custom firewall rules for CoovaChilli start-up
cat > /etc/chilli/ipup.sh <<EOF
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 80 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 443 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 22 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 8000 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 53 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 1812 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -I INPUT -i tun0 -p tcp -m tcp --dport 67 --dst ${TRIM_UAM_IP} -j ACCEPT
EOF

# Custom firewall rules for CoovaChilli shut-down
cat > /etc/chilli/ipdown.sh <<EOF
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 80 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 443 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 22 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 8000 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 53 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 1812 --dst ${TRIM_UAM_IP} -j ACCEPT
iptables -D INPUT -i tun0 -p tcp -m tcp --dport 67 --dst ${TRIM_UAM_IP} -j ACCEPT
EOF


# Fix CoovaChilli Defaults
sed -i 's|HS_UAMALLOW|#HS_UAMALLOW|g' /etc/chilli/defaults
sed -i 's|HS_UAMHOMEPAGE|#HS_UAMHOMEPAGE|g' /etc/chilli/defaults

# Update UAM Secret for rd_login_pages
sed -i "s|<?|<?php|g" ${9}rd_login_pages/services/uam.php > /dev/null 2>&1
sed -i "s|$uamsecret = 'greatsecret';|$uamsecret = '${7}';|g" ${9}rd_login_pages/services/uam.php > /dev/null 2>&1

# if [[ -d "${9}" ]]; then
	# sed -i "s|<?|<?php|g" ${9}rd_login_pages/services/uam.php > /dev/null 2>&1
	# sed -i "s|$uamsecret = 'greatsecret';|$uamsecret = '${7}';|g" ${9}rd_login_pages/services/uam.php > /dev/null 2>&1
# else
# fi

# Disable DNS lookup for SSH
echo "UseDNS no" >> /etc/ssh/sshd_config

}

# Clear Temporary Directory
function clear_dir(){
	cd ~/
	rm -rf ${1}
}

# Utility Functions
function to_lower(){
	echo "${1}" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

function os_distro_type(){
	if [[ -f "/etc/redhat-release" ]] ; then
		DISTRO=`cat /etc/redhat-release | sed s/\ release.*//`
	elif [[ -f "/etc/debian_version" ]] || [[ -f "/etc/lsb-release" ]]; then
		DISTRO=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
	else
		DISTRO="Unsupported"
	fi

	to_lower ${DISTRO}
}

function install_ubuntu_coovachilli(){
if [ "${1}" = "x86_64" ]; then
	wget_download http://maomuffy.com/repo/ubuntu/coovachilli/x86_64/coova-chilli_1.3.0_amd64.deb coova-chilli_1.3.0.deb
else
	wget_download http://ap.coova.org/chilli/coova-chilli_1.3.0_i386.deb coova-chilli_1.3.0.deb
fi
dpkg -i coova-chilli_1.3.0.deb > /dev/null 2>&1
rm -rf coova-chilli_1.3.0.deb
}

function flag_download_complete(){
	touch ${1}download_complete.txt
}

function check_interfaces(){
# Create an empty array
local IFC=()

# for i in `cat /proc/net/dev | grep ':' | cut -d ':' -f 1`
for i in `netstat -i | awk '{print $1}' | tail -n+3`
do
	#ifname=`echo $i | tr -d ' '`
	if [ "${i}" != "lo" ]; then
	   IFC+=("$i")
	fi
done

local CT=${#IFC[@]}

#for ((v=0; v<${CT}; v++))
#do
#    echo ${IFC[$v]}
#done
echo ${CT}
}

########## End Functions #########