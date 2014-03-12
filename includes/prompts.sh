#!/bin/bash

########## Start Prompts #########

# Prompt for Web server technology
function ask_for_webserver(){
	echo ""
	read -p "What web server should we use? [N]ginx or [A]pache: " answer
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
		
		read -p "Database password (Default: rd): " db_password
		[ "${db_password}" = "" ] && db_password="rd"
		
		read -p "Database name (Default: rd): " db_name
		[ "${db_name}" = "" ] && db_name="rd"
		;;
	  n|N|no|No|  )
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
		read -p "RADIUS Secret (Default: testing123) " rad_secret
		[ "${rad_secret}" = "" ] && rad_secret="testing123"
		;;
	  n|N|no|No|  )
		rad_secret="testing123"
		;;
	  * ) 
		rad_secret="testing123"
		;;
	esac
	echo ""
}

########## End Prompts #########