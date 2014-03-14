#!/bin/bash

# Description: CoovaChilli Core Installer.
# Author: Mfawa Alfred Onen
# Link/URL: http://muffycompo.github.io/radiusdesk-installer
# Date: March 14, 2014

# Ensure variables, functions and prompts exist
if [[ ! -e "includes/variables.sh" ]] || [[ ! -e "includes/functions.sh" ]] || [[ ! -e "includes/prompts.sh" ]]; then
	echo "=================================================================================================="
	echo "We can not start the installer because some files are missing, try re-downloading the installer!"
	echo "=================================================================================================="
	exit 1
else
	source includes/variables.sh
	source includes/functions.sh
	source includes/prompts.sh
fi

# Ensure we have two network cards NICs
if [[ ${IF_COUNT} -lt 2 ]]; then
	echo "============================================================"
	echo "You MUST have two or more network interface cards (NICs)!"
	echo "============================================================"
	exit 1
fi

echo "Installing CoovaChilli"

# END