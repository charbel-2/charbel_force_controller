#!/bin/bash

# Copyright 2024 Federico Rollo
#
# Institute: Leonardo Labs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get this script's path
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

set -e

source $SCRIPTPATH/color.cfg

IMAGES=$(ls -d $SCRIPTPATH/../images/* | rev | cut -d "/" -f 1 | rev)

USAGE="Usage: \n install_dependencies [OPTIONS...] 
\n\n
Help Options:
\n 
-h,--help \tShow help options
\n\n
Application Options:
\n 
-i, --image \tSet to build [$IMAGES], example: -s yolact"

if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
	echo -e $USAGE
	exit 0
fi

while [ -n "$1" ]; do # while loop starts
	case "$1" in
         -i|--image)
    		IMAGE="$2"
		shift
		;;	
	*) echo -e "\n${COLOR_WARN}Option $1 not recognized!${COLOR_RESET}\n" 
		echo -e $USAGE
		exit 1;;
	esac
	shift
done

# Checks image
if [[ -d "$SCRIPTPATH/../images/$IMAGE/dependencies" ]]
then 
	echo -e "${COLOR_INFO}Selected image: $IMAGE${COLOR_RESET}"
else
	echo -e "${COLOR_WARN}"The image \<$IMAGE\> seems not to exists!"${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi

apt-get update
apt-get install sudo

# install system dependencies
SYS_DEPS_FILE=$SCRIPTPATH/../images/$IMAGE/dependencies/sys_deps_list.txt
if [[ -s "$SYS_DEPS_FILE" ]]
then 
	echo -e "${COLOR_INFO}Install $IMAGE system libraries${COLOR_RESET}"
	cat $SCRIPTPATH/../images/$IMAGE/dependencies/sys_deps_list.txt | grep -v \# | xargs sudo apt-get install -y
else
	echo -e "${COLOR_WARN}"No sys_deps_list.txt found"${COLOR_RESET}"
fi

# install ros dependencies
ROS_DEPS_FILE=$SCRIPTPATH/../images/$IMAGE/dependencies/ros_deps_list.txt
if [[ -s "$ROS_DEPS_FILE" ]]; then

	ROS_VERSION=`ls /opt/ros/`

	echo -e "${COLOR_INFO}Install $IMAGE ROS packages${COLOR_RESET}"
	# install packages
	cat $ROS_DEPS_FILE | grep -v \# | xargs printf -- "ros-${ROS_VERSION}-%s\n" | xargs sudo apt-get install -y
else
	echo -e "${COLOR_WARN}"No ros_deps_list.txt found"${COLOR_RESET}"
fi

# install python dependencies
PYTHON_DEPS_FILE=$SCRIPTPATH/../images/$IMAGE/dependencies/python_deps_list.txt

if [[ -s "$PYTHON_DEPS_FILE" ]]; then
    echo -e "${COLOR_INFO}Installing Python libraries from $PYTHON_DEPS_FILE...${COLOR_RESET}"

	sudo apt-get install -y python3-pip && pip3 install --upgrade pip

    # Use 'pip install' with the '-r' flag to read from the requirements file.
    # This is the correct and most robust way to install dependencies.
    # It handles comments and empty lines correctly.
    pip3 install -r "$PYTHON_DEPS_FILE"
else
    echo -e "${COLOR_WARN}No valid $PYTHON_DEPS_FILE found. Skipping Python library installation.${COLOR_RESET}"
fi

echo -e "${COLOR_INFO}$IMAGE dependencies installation completed${COLOR_RESET}"

exit 0
