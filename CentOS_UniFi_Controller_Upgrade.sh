#!/bin/sh

# CentOs_UniFi_Controller_Upgrade.sh
# UniFi Controller Upgrade Script for CentOs 7 Systems
# by Steven Marks <spottedhyena.co.uk>
# Version 1.0
# Inspiration from: Steve Jenkins

# REQUIREMENTS
# 1) UniFi Controller installed and running.
# 2) Requires the following service script:
# 3) Requires wget.

# USAGE
# Modify the "UNIFI_DOWNLOAD" variable below using the full URL of
# the UniFi Controller zip file on Ubiquiti download site. Optionally modify
# any of the additional variables below (defaults should work fine),
# then run the script!

# CONFIGURATION OPTIONS
UNIFI_DOWNLOAD=http://dl.ubnt.com/unifi/5.4.11/UniFi.unix.zip
UNIFI_FILENAME=UniFi.unix.zip
UNIFI_SERVICE=unifi
UNIFI_PARENT_DIR=/opt
UNIFI_DIR=/opt/UniFi
UNIFI_BACKUP_DIR=/opt/UniFi_bak
TEMP_DIR=/tmp

#### DO NOT MODIFY PAST THIS POINT ####

# Create progress dots function
show_dots() {
	while ps $1 >/dev/null ; do
	printf "."
	sleep 1
	done
	printf "\n"
}

# start upgrade
printf "Starting UniFi Controller Upgrade...\n"

# Retrieve the latest zip archive from Ubiquiti
printf "\nDownloading %s from Ubiquiti..." "$UNIFI_DOWNLOAD"
cd $TEMP_DIR || exit
wget -qq $UNIFI_DOWNLOAD -O $UNIFI_FILENAME &
show_dots $!

# Check to make sure the file downloaded correctly

if [ -f "$UNIFI_FILENAME" ]; then

	# Remove previous backup directory (if it exists)
	if [ -d "$UNIFI_BACKUP_DIR" ]; then
		printf "\nRemoving previous backup directory...\n"
		rm -rf $UNIFI_BACKUP_DIR
	fi

	# copy existing UniFi directory to backup location
	printf "\nCopy UniFi Controller directory to backup location...\n"
	\cp -R $UNIFI_DIR $UNIFI_BACKUP_DIR

	# Extract new version
	printf "\nExtracting downloaded software..."
	unzip -o -qq $TEMP_DIR/$UNIFI_FILENAME -d $UNIFI_PARENT_DIR &
	show_dots $!

	# Copy the data into the new UniFi Controller directory
	printf "\nCopy UniFi Controller backup data to new directory..."
	\cp -R -f $UNIFI_BACKUP_DIR/data/ $UNIFI_PARENT_DIR/data/ &
	show_dots $!

	# start the UniFi Controller service
	printf "\nStarting Controller, please standby...\n"
	systemctl start $UNIFI_SERVICE
	until $(curl --output /dev/null -k --silent --head https://localhost:8443); do 
		show_dots $! 
	done

	# fin!
	printf "\nUpgrade of UniFi Controller complete, you may now login\n"

	exit 0

else

	# Archive file doesn't exist, warn and exit
	printf "\nUniFi Controller software not found! Please check download link.\n"

	exit 1
fi
