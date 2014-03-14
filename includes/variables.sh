#!/bin/bash

########## Start Installer Variables #########
RD_INSTALLER_VERSION='1.0.1'
ARCH_TYPE=`arch`
OS_VERSION=`awk -F' ' '{ print $0 }' /etc/redhat-release | grep -o "[0-9]" | head -1`
CONF_DIR='conf/'
TEMP_PATH='/tmp/radiusdesk/'
SOURCE_DIR='source/'
IP_ADDRESS=`ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'`
SUDOERS_FILE='/etc/sudoers'
RADIUS_DIR='/etc/raddb/'
IF_COUNT=`ifconfig | egrep '^eth' | wc -l`
  
# Color Guide
LIGHT_RED='\e[91m'
LIGHT_GREEN='\e[92m'
LIGHT_BLUE='\e[94m'
LIGHT_YELLOW='\e[93m'

# Formatting Options
BOLD='\e[1m'
F_END='\e[0m'

########## End Installer Variables #########