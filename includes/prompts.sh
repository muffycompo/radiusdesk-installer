#!/bin/bash

########## Start Prompts #########

# Prompt for Web server technology
function ask_for_webserver(){
	echo
	read -p "Pick a web server to use? [N]ginx or [A]pache: " answer
	case "${answer}" in 
	  n|N|nginx|Nginx )
		echo
		echo -e "Using ${LIGHT_BLUE}${BOLD}Nginx${F_END} Web server"
		webserver="nginx";;
	  a|A|apache|Apache )
		echo
		echo -e "Using ${LIGHT_BLUE}${BOLD}Apache${F_END} Web server"
		if [[ "${1}" = "red" ]] || [[ "${1}" = "centos" ]]; then
			webserver="httpd"
		elif [[ "${1}" = "ubuntu" ]]; then
			webserver="apache2"
		fi
		;;
	  * )
		echo
		echo -e "${LIGHT_RED}Oops...something went wrong, perharps you made a mistake in your selection!${F_END}"
		exit 1;;
	esac
}

# Prompt for System Reboot
function ask_for_reboot(){
	echo
	read -p "Do you want to reboot your computer now? [Y]es or [N]o: " answer
	case "${answer}" in 
	  y|Y|yes|Yes )
		echo
		echo -e "${LIGHT_RED}${BOLD}Rebooting...${F_END}will be back in minute :)"
		init 6;;
	  n|N|no|No )
		echo
		echo -e "No biggy...maybe later :)";;
	  * ) 
		exit 1;;
	esac
}

# Prompt MySQL Database Customization
function ask_for_database_customization(){
	echo
	read -p "Do you want to customize database credentials? [N]o or [Y]es : " y_n
	case "${y_n}" in 
	  y|Y|yes|Yes )
		read -p "Database host (Default: localhost) " db_host
		[ "${db_host}" = "" ] && db_host="localhost"
		
		read -p "Database user (Default: rd): " db_user
		[ "${db_user}" = "" ] && db_user="rd"
		
		# Mask password enter and replace with *
		unset sec_pass
		prompt="Database password (Default: rd): "
		while IFS= read -p "${prompt}" -r -s -n 1 sec_pass
			do
				if [[ ${sec_pass} == $'\0' ]]
					then
						break
					fi
				prompt='*'
				db_password+="${sec_pass}"
		done
		[ "${db_password}" = "" ] && db_password="rd"
		echo
		
		read -p "Database name (Default: rd): " db_name
		[ "${db_name}" = "" ] && db_name="rd"
		;;
	  n|N|no|No )
		db_host="localhost"
		db_user="rd"
		db_password="rd"
		db_name="rd"
		;;
	  * )
		db_host="localhost"
		db_user="rd"
		db_password="rd"
		db_name="rd"
		;;
	esac
	echo
}

# Prompt FreeRADIUS Customization
function ask_for_radius_customization(){
	echo
	read -p "Do you want to customize RADIUS credentials? [N]o or [Y]es : " y_n
	case "${y_n}" in 
	  y|Y|yes|Yes )
		# Mask secret enter and replace with *
		unset rad_pass
		rad_prompt="RADIUS Secret (Default: testing123) "
		while IFS= read -p "${rad_prompt}" -r -s -n 1 rad_pass
			do
				if [[ ${rad_pass} == $'\0' ]]
					then
						break
					fi
				rad_prompt='*'
				rad_secret+="${rad_pass}"
		done
		[ "${rad_secret}" = "" ] && rad_secret="testing123"
		echo
		;;
	  n|N|no|No)
		rad_secret="testing123"
		;;
	  * ) 
		rad_secret="testing123"
		;;
	esac
	echo
}

# Prompt CoovaChilli Customization
function ask_for_coovachilli_customization(){
	echo
	read -p "WAN Interface (Default: eth0) " wan_if
	[ "${wan_if}" = "" ] && wan_if="eth0"

	read -p "LAN Interface (Default: eth1) " lan_if
	[ "${lan_if}" = "" ] && lan_if="eth1"

	read -p "LAN Network (Default: 192.168.1.0) " lan_net
	[ "${lan_net}" = "" ] && lan_net="192.168.1.0"

	read -p "LAN Subnet Mask (Default: 255.255.255.0) " lan_sm
	[ "${lan_sm}" = "" ] && lan_sm="255.255.255.0"

	# Mask password enter and replace with *
	unset uam
	uam_prompt="UAM Secret (Default: uam_s3cr3t) "
	while IFS= read -p "${uam_prompt}" -r -s -n 1 uam
		do
			if [[ ${uam} == $'\0' ]]
				then
					break
				fi
			uam_prompt='*'
			uam_secret+="${uam}"
	done
	[ "${uam_secret}" = "" ] && uam_secret="uam_s3cr3t"
	echo

	read -p "RADIUSdesk Server IP (Default: localhost) " radiusdesk_ip
	[ "${radiusdesk_ip}" = "" ] && radiusdesk_ip="localhost"

	# Mask password enter and replace with *
	unset rad_sec_chilli
	rad_sec_prompt="RADIUS Secret (Default: testing123) "
	while IFS= read -p "${rad_sec_prompt}" -r -s -n 1 rad_sec_chilli
		do
			if [[ ${rad_sec_chilli} == $'\0' ]]
				then
					break
				fi
			rad_sec_prompt='*'
			radius_secret+="${rad_sec_chilli}"
	done
	[ "${radius_secret}" = "" ] && radius_secret="testing123"
	echo
	echo
}


# Prompt for CoovaChilli Installation
function ask_for_coovachilli_install(){
	read -p "Will you like to setup CoovaChilli Captive Portal? [Y]es or [N]o: " chilli_answer
	case "${chilli_answer}" in 
	  y|Y|yes|Yes )
		# Ensure we have two network cards NICs
		if [[ ${IF_COUNT} -lt 2 ]]; then
		echo "============================================================"
		echo -e "${LIGHT_RED}${BOLD}You MUST have atleast two network interface cards (NICs)!${F_END}"
		echo "============================================================"
		exit 1
		fi
		
		# CoovaChilli Customization Prompt
		ask_for_coovachilli_customization
		
		# Install CoovaChilli 1.3.0 from maorepo
		echo
		echo "============================================================="
		echo -e "Installing ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
		yum_install coova-chilli vixie-cron
		
		#configure CoovaChilli
		echo
		echo "============================================================="
		echo -e "Configuring ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
		configure_coovachilli ${COOVACHILLI_DIR} ${wan_if} ${lan_if} ${lan_net} ${lan_sm} ${radius_secret} ${uam_secret} ${radiusdesk_ip} ${1}

		# Start CoovaChilli on Boot
		start_service_on_boot chilli

		# Start CoovaChilli
		restart_service chilli

		;;
	  n|N|no|No ) echo;;
	  * ) echo;;
	esac
}

# Prompt for CoovaChilli Installation
function ask_for_coovachilli_install_ubuntu(){
	read -p "Will you like to setup CoovaChilli Captive Portal? [Y]es or [N]o: " chilli_answer
	case "${chilli_answer}" in 
	  y|Y|yes|Yes )
		# Ensure we have two network cards NICs
		if [[ ${IF_COUNT} -lt 2 ]]; then
		echo "============================================================"
		echo -e "${LIGHT_RED}${BOLD}You MUST have atleast two network interface cards (NICs)!${F_END}"
		echo "============================================================"
		exit 1
		fi
		
		# CoovaChilli Customization Prompt
		ask_for_coovachilli_customization
		
		# Install CoovaChilli 1.3.0 from maorepo
		echo
		echo "============================================================="
		echo -e "Installing ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
		get_to ${TEMP_PATH}
		wget_download http://ap.coova.org/chilli/coova-chilli_1.3.0_i386.deb coova-chilli_1.3.0_i386.deb
		dpkg -i coova-chilli*.deb > /dev/null 2>&1
		
		#configure CoovaChilli
		echo
		echo "============================================================="
		echo -e "Configuring ${LIGHT_BLUE}${BOLD}CoovaChilli 1.3.0${F_END}"
		configure_coovachilli ${COOVACHILLI_DIR} ${wan_if} ${lan_if} ${lan_net} ${lan_sm} ${radius_secret} ${uam_secret} ${radiusdesk_ip} ${1}

		# Enable Chilli
		sed -i 's|START_CHILLI=0|START_CHILLI=1|g' /etc/default/chilli
		
		# Start CoovaChilli on Boot
		start_ubuntu_service_on_boot chilli

		# Start CoovaChilli
		start_ubuntu_service chilli

		;;
	  n|N|no|No ) echo;;
	  * ) echo;;
	esac
}

########## End Prompts #########