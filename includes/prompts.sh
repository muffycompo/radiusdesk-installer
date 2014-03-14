#!/bin/bash

########## Start Prompts #########

# Prompt for Web server technology
function ask_for_webserver(){
	echo ""
	read -p "Pick a web server to use? [N]ginx or [A]pache: " answer
	case "${answer}" in 
	  n|N|nginx|Nginx )
		echo ""
		echo -e "Using ${LIGHT_BLUE}${BOLD}Nginx${F_END} Web server"
		webserver="nginx";;
	  a|A|apache|Apache )
		echo ""
		echo -e "Using ${LIGHT_BLUE}${BOLD}Apache${F_END} Web server"
		webserver="httpd";;
	  * )
		echo ""
		echo -e "${LIGHT_RED}Oops...something went wrong, perharps you made a mistake in you selection!${F_END}"
		exit 1;;
	esac
}

# Prompt for System Reboot
function ask_for_reboot(){
	echo ""
	read -p "Do you want to reboot your computer now? [Y]es or [N]o: " answer
	case "${answer}" in 
	  y|Y|yes|Yes )
		echo ""
		echo -e "${LIGHT_RED}${BOLD}Rebooting...${F_END}will be back in minute :)"
		init 6;;
	  n|N|no|No )
		echo ""
		echo -e "No biggy...we will do it later time :)";;
	  * ) 
		exit 1;;
	esac
}

# Prompt MySQL Database Customization
function ask_for_database_customization(){
	echo ""
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
	echo ""
}

# Prompt FreeRADIUS Customization
function ask_for_radius_customization(){
	echo ""
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
	echo ""
}

# Installer Menu
function installer_menu(){
	echo "===================================="
	echo -e "Welcome to RADIUSdesk Installer"
	echo "===================================="
	echo -e "1) Install RADIUSdesk"
	echo -e "2) Install CoovaChilli (if you need a Captive Portal)"
	echo -e "3) Quit or q"
	echo -n "Select an option: "
	read menu_opt
	case "${menu_opt}" in
		1) echo "Installing RADIUSdesk";;
		2) echo "Installing CoovaChilli";;
		3|q) echo "Quiting Installer";;
		*) 
		echo "Invalid selection!"
		exit 1;;
	
	esac
}


# Prompt CoovaChilli Customization
function ask_for_coovachilli_customization(){
	echo ""
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


########## End Prompts #########