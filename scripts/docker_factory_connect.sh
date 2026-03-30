#!/bin/bash

# Copyright 2024 Giuseppe Alfonso, Valentina Pericu, Federico Rollo
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

CONTAINERS=$(docker ps --format "{{.Names}}")

USAGE="Usage: \n docker_factory_connect CONTAINER_NAME
\n\n
Available CONTAINER_NAMEs: [${COLOR_INFO}$CONTAINERS${COLOR_RESET}]
\n\n
Help Options:
\n
-h,--help \tShow help options
\n
"

if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
	echo -e $USAGE
	exit 0
fi

# Read container name 
CONTAINER_NAME="$1"

# Check if container name is provided in command line
if [[ -z "$CONTAINER_NAME" ]]; then
    echo -e "${COLOR_WARN}"No container name specified! Please provide the name of the container to run."${COLOR_RESET}"
	echo -e $USAGE
    exit 1
fi

shift

# Print info
echo -e "${COLOR_INFO}Connecting to container: $CONTAINER_NAME${COLOR_RESET}"

# Checks
if [[ ${CONTAINERS[@]} =~ $CONTAINER_NAME  ]]
then 
    docker exec \
		--env TERM=xterm-256color \
		--env SSH_AUTH_SOCK=/ssh-agent \
		-it $CONTAINER_NAME \
		/bin/bash
else
	echo -e "${COLOR_WARN}"Wrong container name!"${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi