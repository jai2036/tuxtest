#!/bin/sh

#
# Author: Jayanta M., 12-sep-21
#

CURDIR=`pwd`
INSTALLER=tuxedo121300_64_Linux_01_x86.zip
PATCH=`ls p*_121300_Linux-x86-64.zip`
if [ ! -z "$1" ]
    then
	PATCH=$1
	if [ ! -z "$2" ]
	    then
		INSTALLER=$2
	fi
fi
echo "Using patch file $PATCH"
echo "Using Tuxedo installer $INSTALLER"
# Unzip the downloaded installation kit to the current directory
cd /home/tuxdev/Downloads
unzip -qq /home/tuxdev/Downloads/$INSTALLER
# Run the installer in silent mode
# 
# Need to create oraInst.loc first:
echo "inventory_loc=/home/tuxdev/oraInventory" > /home/tuxdev/Downloads/oraInst.loc
echo "inst_group=tuxdev" >> /home/tuxdev/Downloads/oraInst.loc
#
./Disk1/install/runInstaller -invPtrLoc /home/tuxdev/Downloads/oraInst.loc -responseFile $CURDIR/tuxedo12.1.3.rsp -silent -waitforcompletion
#
# Remove the installer and generated response file
rm -Rf Disk1 tuxedo12.1.3.rsp $INSTALLER
echo "Tuxedo installation done"
#
# Install rolling patch
if [ -e $PATCH ]
    then
	echo "Starting patch"
	export ORACLE_HOME=/home/tuxdev/app
	unzip -qq /home/tuxdev/Downloads/$PATCH
	rm -Rf /home/tuxdev/Downloads/$PATCH
	$ORACLE_HOME/OPatch/opatch apply -invPtrLoc /home/tuxdev/Downloads/oraInst.loc *.zip
fi



