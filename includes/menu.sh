#!/bin/bash

########## Start Menu #########
source includes/variables.sh

# Installer Menu
function installer_menu(){
	echo "========================================="
	echo -e "${LIGHT_BLUE}${BOLD}Welcome to RADIUSdesk Installer${F_END} ${LIGHT_RED}${BOLD}v${RD_INSTALLER_VERSION}${F_END}"
	echo "========================================="
	echo -e "1) Install RADIUSdesk"
	echo -e "2) Install CoovaChilli (if you need a Captive Portal)"
	echo -e "3) Quit or q"
	echo -n "Select an option: "
	read menu_opt
	case "${menu_opt}" in
		1) source rhel_centos_core.sh;;
		2) source coovachilli_core.sh;;
		3|q) exit 1;;
		*) 
		echo "Invalid selection!"
		exit 1;;
	
	esac
}

# Show RADIUSdesk Installer Version
function show_version(){
	while getopts ":v-:" opt; do
	  case $opt in
		v)
		  echo -e "RADIUSdesk Installer ${LIGHT_BLUE}${BOLD}${RD_INSTALLER_VERSION}${F_END}" >&2
		  exit 0;;
		-)
			case $OPTARG in
			 version) echo -e "RADIUSdesk Installer ${LIGHT_BLUE}${BOLD}${RD_INSTALLER_VERSION}${F_END}" >&2
			 exit 0;;
			 *) 
			 echo -e "Usage: ${LIGHT_BLUE}${BOLD}./$(basename $0) -v | --version${F_END}" >&2
			 exit 1;;
			esac;;
		\?)
		  echo -e "Usage: ${LIGHT_BLUE}${BOLD}./$(basename $0) -v | --version${F_END}" >&2
		  exit 1
		  ;;
	  esac
	done
}

########## End Menu #########