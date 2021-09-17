#!/bin/bash
#
# Created by: Jayanta Mohanty , 8-sep-21
#
echo "====================="
#

if [ ! -e tuxedo121300_64_Linux_01_x86.zip ]
then
  echo "Download the Tuxedo 12cR2 ZIP Distribution and"
  echo "drop the file tuxedo121300_64_Linux_01_x86.zip in this folder before"
  echo "building this Tuxedo Docker container!"
  exit 
fi


if [ ! -e p*_121300_Linux-x86-64.zip ]
then
  echo "Installing Tuxedo without any patches"
fi


echo "====================="

docker rmi "appd/tuxedo"
if [ "$?" = "0" ]
  then
  echo "Cleaning ..."
  else 
  echo "[image]/tuxedo , does not exist, so its going to be fresh build"
fi 

docker build . -t appd/tuxedo 
if [ "$?" = "0" ]
    then
	echo ""
	echo "Tuxedo Docker image is ready to be used. To create a container, run:"
	echo "docker run -it  appd/tuxedo /bin/bash"
    else
	echo "Build of Tuxedo Docker image failed."
fi

