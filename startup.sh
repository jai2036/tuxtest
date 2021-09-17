#!/bin/sh
#
# Author: Jayanta Mohanty , 8-sep-21
#
# Usage: source startup.sh
#
if [ ! -z "$1" ]
    then
	export TUXDIR=$1
elif [ -z "$TUXDIR" ]
    then
	export TUXDIR=~/app/tuxedo12.1.3.0.0
fi

# clean up from any previous run
tmshutdown -y &>/dev/null 
rm -Rf simpcl simpserv tuxconfig ubbsimple ULOG.*

# Create environment setup script setenv.sh
export HOSTNAME=`hostname`
export APPDIR=`pwd`

cat >setenv.sh << EndOfFile
source  ${TUXDIR}/tux.env
export HOSTNAME=${HOSTNAME}
export APPDIR=${APPDIR}
export TUXCONFIG=${APPDIR}/tuxconfig
export IPCKEY=112233
EndOfFile
source ./setenv.sh

# Create the Tuxedo configuration file
cat >ubbsimple << EndOfFile
*RESOURCES
IPCKEY		$IPCKEY
DOMAINID	simpapp
MASTER		site1
MAXACCESSERS	50
MAXSERVERS	20
MAXSERVICES	10
MODEL		SHM
LDBAL		Y

*MACHINES
"$HOSTNAME"	LMID=site1
		APPDIR="$APPDIR"
		TUXCONFIG="$APPDIR/tuxconfig"
		TUXDIR="$TUXDIR"

*GROUPS
APPGRP		LMID=site1 GRPNO=1 OPENINFO=NONE

*SERVERS
simpserv	SRVGRP=APPGRP SRVID=1 CLOPT="-A"

*SERVICES
TOUPPER
EndOfFile

# Get the sources if not already in this directory
if [ ! -r simpcl.c ]
    then
	cp $TUXDIR/samples/atmi/simpapp/simpcl.c .
fi
if [ ! -r simpserv.c ]
    then
	cp $TUXDIR/samples/atmi/simpapp/simpserv.c .
fi

# Compile the configuration file and build the client and server
tmloadcf -y ubbsimple
# The below is only required when we test the tux environment
buildclient -o simpcl -f simpcl.c

# Build the service
buildserver -o simpserv -f simpserv.c -s TOUPPER

#Build client , instrumented with Appd SDK.
CFLAGS="-I/opt/appdynamics-cpp-sdk/include -Wall -std=c++11 -lpthread -ldl -lrt -L/opt/appdynamics-cpp-sdk/lib -lappdynamics"; 
export CFLAGS 
buildclient -o simpapp -f simpclappd.cpp &> simpapp_out.cmpl

tmboot -y

#./simpcl "If you see this message, tuxedo client app ran OK"
./simpapp "If you see this message, simpapp ran OK" 50

echo "Shutdown the domain .."
tmshutdown -y

echo "======================="
echo "To run client app manually follow below steps:"

echo "a. Boot all domain by: tmboot -y"
echo "b. Run your client app by: ./simpapp \"If you see this message, this app ran OK\" 50"
echo "c. Shutdown the domain: tmshutdown -y"
echo "======================="


