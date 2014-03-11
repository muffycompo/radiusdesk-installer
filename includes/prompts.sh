#!/bin/bash

########## Start Prompts #########

function ask_for_webserver(){
	read -p "What web server should we use? [N]ginx or [A]pache: " answer
	case "${answer}" in 
	  n|N|nginx|Nginx ) 
		echo -e "Using ${LIGHT_BLUE}${BOLD}Nginx${F_END} Web server"
		webserver="nginx";;
	  a|A|apache|Apache ) 
		echo -e "Using ${LIGHT_BLUE}${BOLD}Apache${F_END} Web server"
		webserver="httpd";;
	  * ) 
		  echo -e "${LIGHT_RED}Oops...something went wrong, perharps you made a mistake in you selection!${F_END}"
		  exit 1;;
	esac
}

function ask_for_reboot(){
	read -p "Do you want to reboot your computer now? [Y]es or [N]o: " answer
	case "${answer}" in 
	  y|Y|yes|Yes ) 
		echo -e "${LIGHT_RED}${BOLD}Rebooting...${F_END}will be back in second :)"
		init 6;;
	  n|N|no|No ) 
		echo -e "No biggy...we will do it another time :)";;
	  * ) 
		exit 1;;
	esac
}

########## End Prompts #########