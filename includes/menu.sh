#!/bin/bash

########## Start Menu #########
source includes/variables.sh

# Installer Menu
function installer_menu(){
	echo "========================================="
	echo -e "${LIGHT_BLUE}${BOLD}Welcome to RADIUSdesk Installer${F_END} ${LIGHT_RED}${BOLD}v${RD_INSTALLER_VERSION}${F_END}"
	echo "========================================="
	echo -e "1) Setup RADIUSdesk"
	echo -e "2) Setup CoovaChilli Captive Portal (Optional)"
	echo -e "3) Quit or q"
	echo -n "Select an option: "
	read menu_opt
	case "${menu_opt}" in
		1) 
		if [[ "${1}" = "red" ]] || [[ "${1}" = "centos" ]]; then
			source includes/rhel_centos_core.sh
		elif [[ "${1}" = "ubuntu" ]]; then
			source includes/ubuntu_core.sh
		fi
		;;
		2) 
		if [[ "${1}" = "red" ]] || [[ "${1}" = "centos" ]]; then
			source includes/coovachilli_core.sh
		elif [[ "${1}" = "ubuntu" ]]; then
			source includes/coovachilli_ubuntu_core.sh
		fi
		;;
		3|q) 
		echo -e "${LIGHT_RED}${BOLD}Exiting Installer...:(${F_END}"
		exit 1;;
		*) 
		echo -e "${LIGHT_RED}${BOLD}Invalid selection!${F_END}"
		exit 1;;
	
	esac
}

# Show RADIUSdesk Installer Version
function show_version(){
	while getopts ":v-:" opt; do
	  case $opt in
		v)
			echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
			echo -e "${LIGHT_BLUE}${BOLD}#${F_END}                    ${LIGHT_RED}${BOLD}RADIUSDesk INSTALLER${F_END}                    ${LIGHT_BLUE}#${F_END}" >&2
			echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
			echo -e " Version: ${LIGHT_RED}${BOLD}${RD_INSTALLER_VERSION}${F_END}" >&2
			echo -e "  Author: ${LIGHT_RED}${BOLD}Mfawa Alfred Onen${F_END}" >&2
			echo -e " License: ${LIGHT_RED}${BOLD}Apache License${F_END}" >&2
			echo -e " Website: ${LIGHT_RED}${BOLD}http://muffycompo.github.io/radiusdesk-installer${F_END}" >&2
			echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
		  exit 0;;
		-)
			case $OPTARG in
			 version) 
				echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
				echo -e "${LIGHT_BLUE}${BOLD}#${F_END}                    ${LIGHT_RED}${BOLD}RADIUSDesk INSTALLER${F_END}                    ${LIGHT_BLUE}#${F_END}" >&2
				echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
				echo -e " Version: ${LIGHT_RED}${BOLD}${RD_INSTALLER_VERSION}${F_END}" >&2
				echo -e "  Author: ${LIGHT_RED}${BOLD}Mfawa Alfred Onen${F_END}" >&2
				echo -e " License: ${LIGHT_RED}${BOLD}Apache License${F_END}" >&2
				echo -e " Website: ${LIGHT_RED}${BOLD}http://muffycompo.github.io/radiusdesk-installer${F_END}" >&2
				echo -e "${LIGHT_BLUE}${BOLD}#============================================================#${F_END}" >&2
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