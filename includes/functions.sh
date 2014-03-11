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
		echo -e "${LIGHT_YELLOW}${BOLD}Corrected${F_END}"
	else
		echo -e "${LIGHT_GREEN}${BOLD}Disabled${F_END}"
	fi
}

# Reset IPTables
function reset_iptables_rules(){
	${1} -F
	${1} -X 
	service iptables save > /dev/null 2>&1
}

# YUM Installer
function yum_install(){
	yum -q install -y ${@} > /dev/null 2>&1
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
		yum -q --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap > /dev/null 2>&1
	else
		wget -q -O /etc/yum.repos.d/maorepo-el6-i386.repo http://www.maomuffy.com/freeradius/repo/maorepo-el6-i386.repo
		yum -q --disablerepo=\* --enablerepo=maorepo install -y freeradius freeradius-mysql freeradius-perl freeradius-python freeradius-ldap > /dev/null 2>&1
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

# Restart Service
function restart_service(){
	service ${1} restart > /dev/null 2>&1
}

# Stop Service
function stop_service(){
	service ${1} stop > /dev/null 2>&1
}

# Start Service on Boot
function start_service_on_boot(){
	chkconfig ${1} on
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

# Copy Apache Config
function copy_apache_configs(){
	# 1) Apache: httpd.conf
	cp -aR ${1}php.ini /etc/
	cp -aR ${1}apache/httpd.conf /etc/httpd/conf/
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
	npm -g install tail socket.io connect mysql forever > /dev/null 2>&1
	cd ../
	# Fix Paths for RHEL/CentOS compatibility
	sed -i 's|NODE_BIN_DIR="/usr/bin"|NODE_BIN_DIR="/usr/local/bin"|g' ${3}nodejs-socket-io
	sed -i 's|/usr/lib/node_modules|/usr/local/lib/node_modules|g' ${3}nodejs-socket-io
	sed -i "s|/usr/share/nginx/www/html/|${2}|g" ${3}nodejs-socket-io
	sed -i "s|/usr/share/nginx/www/cake2|${2}cake2|g" ${3}nodejs-socket-io
	sed -i "s|/usr/local/var/|/var/|g" ${2}cake2/rd_cake/Setup/Node.js/Logfile.node.js
	# Add to chkconfig
	chkconfig --add nodejs-socket-io
}

# Install RADIUSdesk
function install_radiusdesk(){
	get_to ${1}
	cp -aR ${2}rd_cake ${3}cake2/
	cp -aR ${2}rd2 ${3}rd
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

# Update RADIUSdesk Paths
function update_radiusdesk_paths(){
	sed -i 's|/usr/local/share|/usr/share|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|/usr/local/etc/raddb|/etc/raddb|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|/usr/local/bin|/usr/bin|g' ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i "s|'id' => 'pptp',     'active' => false|'id' => 'pptp',     'active' => true|g" ${1}cake2/rd_cake/Config/RadiusDesk.php
	sed -i 's|<script src="ext/ext-dev.js"></script>|<script src="ext/ext-all.js"></script>|g' ${1}rd/index.html
	sed -i 's|Ext.Loader.setConfig({enabled:true});|Ext.Loader.setConfig({enabled:true,disableCaching: false});|g' ${1}rd/app.js 
}

# Install RADIUSdesk MySQL Schema
function install_radiusdesk_schema(){
	${1} -u root -e "CREATE DATABASE rd;" > /dev/null 2>&1
	${1} -u root -e "GRANT ALL PRIVILEGES ON rd.* to 'rd'@'127.0.0.1' IDENTIFIED BY 'rd';" > /dev/null 2>&1
	${1} -u root -e "GRANT ALL PRIVILEGES ON rd.* to 'rd'@'localhost' IDENTIFIED BY 'rd';" > /dev/null 2>&1
	${1} -u root rd < ${2}cake2/rd_cake/Setup/Db/rd.sql > /dev/null 2>&1
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
	cat ${OLDPWD}/utils/dynamic-clients > ${2}sites-enabled/dynamic-clients

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

# Create Temporary Directory
function mk_temp_dir(){
	mkdir -p /tmp/radiusdesk/
}

# Clear Temporary Directory
function clear_dir(){
	cd ~/
	rm -rf ${1}
}


########## Start Functions #########