# Introduction
Appd instrumentaion to monitor tuxedo C++ app using c/c++ sdk.

## How to use

1. Unzip tuxtest.zip
2. Update appd config in simpclappd.cpp
3. Execute build.sh

**Pre-requisites**:
1. Install docker
2. Download the following files to current directory in case it is not present:

    2.a. tuxedo121300_64_Linux_01_x86.zip	from http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html

    2.b. p22090512_121300_Linux-x86-64.zip 	or whatever the latest Tuxedo rolling patch is from My Oracle Support

You should end up with a docker image tagged appd/tuxedo

You can then start the image in a new container with:  `docker run -it appd/tuxedo /bin/bash`
which will put you into the container with a bash prompt. Simply execute the `source startup.sh` the script will build and run the Tuxedo simpapp application with appd instrumentation.

Have fun!



