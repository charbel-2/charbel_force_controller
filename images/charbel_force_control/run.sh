#!/usr/bin/env bash

# Copyright 2024 Simone Giampà
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

# Immediately exit if any command within the script returns a non-zero exit status
set -e 

# Load color definitions from configuration file
source $SCRIPTPATH/color.cfg

# Help print message
USAGE="Usage: \n run [OPTIONS...] 
\n\n
Help Options:
\n 
-h,--help \t\tShow help options
\n\n
Application Options:
\n 
-i,--interactive \tRun docker in interactive mode
\n 
-t,--tag \tSelect a specific docker tag
"

# Print help info if requested
if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
	echo -e $USAGE
	exit 0
fi

# Load the configuration file
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/docker_run.cfg"

# Read command line arguments
while [ -n "$1" ]; do # while loop starts
	case "$1" in
	-i|--interactive)
		# Set command for interactive mode
		CMD=$CMD_INTERACTIVE
		;;
	-t|--tag)
		# Set specific Docker tag
		TAG="$2"
		shift
		;;
	-n|--name)
		# Set the container name
		CONTAINER_NAME="$2"
		shift
		;;
	*) 
		# Handle unrecognized options
		echo "Option $1 not recognized!" 
		echo -e $USAGE
		exit 0;;
	esac
	shift
done

# Get the list of currently running Docker containers
CONTAINERS=$(docker ps --format "{{.Names}}")

# Check if a container name was provided
if [[ -z $CONTAINER_NAME ]]; then
	CONTAINER_NAME=$IMAGE
# Ensure the container name is unique
elif [[ ${CONTAINERS[@]} =~ $CONTAINER_NAME  ]]; then
	echo -e "The container name: $CONTAINER_NAME already exists. Choose another name."
	echo -e $USAGE
	exit 0
fi


# Use this command when you want to allow the Docker container to access the host's X server 
# without creating and managing an Xauthority file. 
# This is generally more straightforward and less secure, as it grants all local containers access 
# to the X server. Suitable for development or quick setups but not recommended for production.
xhost +local:docker

# Use the following block when you need to create and manage X11 authentication cookies 
# for secure X11 forwarding between your host and the Docker container.
# This is typically necessary when you want fine-grained control over X11 access
# or when running GUI applications in Docker that need to interact with the host's display.
# It creates an Xauthority file and ensures the Docker container can access the display securely.
# XAUTH=/tmp/.docker.xauth
# if [ ! -f $XAUTH ]
# then
#     touch $XAUTH
#     xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
# fi

chmod +rw ~/.bash_history
chmod o+w ~/.bash_history

# Print information about the container being run
echo -e "${COLOR_INFO}Running container: ${COLOR_INFO}$CONTAINER_NAME${COLOR_RESET}"

# Run the Docker container with the specified options
docker run --user root:root \
           --hostname $HOSTNAME \
		   --name $CONTAINER_NAME \
		   --env="HISTFILE=/home/$USERNAME/.bash_history" \
           --env="HISTFILESIZE=2000" \
		   --net=host \
		   --ipc=host \
		   --pid=host \
		   --device /dev/dri/ \
		   --device /dev/video0 \
		   --device /dev/bus/usb \
		   -v /dev:/dev \
		   --privileged -e "QT_X11_NO_MITSHM=1" \
           -e DISPLAY=$DISPLAY \
		   -e RMW_IMPLEMENTATION \
		   -e SHELL \
		   -v $SSH_AUTH_SOCK:/ssh-agent \
		   -e SSH_AUTH_SOCK=/ssh-agent \
		   -v ~/.bash_history:/home/$USERNAME/.bash_history \
           --volume $HOME/.Xauthority:/root/.Xauthority:ro \
		   --volume /dev/shm:/dev/shm \
           -it $IMAGE:$TAG $SHELL \
		   -c "$CMD"