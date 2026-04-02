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

IMAGES=$(find $HOME/utils/docker_factory/images -name run.sh | cut -d "/" -f7- | rev | cut -d "/" -f2- | rev )

USAGE="Usage: \n docker_factory_run IMAGE_NAME [OPTIONS...] 
\n\n
Available IMAGE_NAMEs: [${COLOR_INFO}$IMAGES${COLOR_RESET}]
\n\n
Help Options:
\n
-h,--help \tShow help options
\n\n
Application Options:
\n 
-i,--interactive \tTo launch in interactive mode
\n 
-t,--tag \tTo pass a specific tag, example: -t latest
\n 
-n,--name \tTo assign a name to the container, example: -n example
\n 
-a,--arg \tTo pass arguments to the specific image run file, format: -a arg_name arg_value (they should be passed as the lasts arguments)
"

IMAGE=
TERMINAL=

CMD=""
CMD_INTERACTIVE="-i"

if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
	echo -e $USAGE
	exit 0
fi

# Read image
IMAGE="$1"

# Check if image name is provided in command line
if [ -z "$IMAGE" ]; then
    echo -e "${COLOR_WARN}"No image name specified! Please provide the name of the image to run."${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi

shift


# Checks
if [ -f "$SCRIPTPATH/../images/$IMAGE/run.sh" ]
then 
	echo -e "Selected image: ${COLOR_INFO}$IMAGE${COLOR_DEFAULT}"
else
	echo -e "${COLOR_WARN}"Wrong image option!"${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi

while [ -n "$1" ]; do # while loop starts
	case "$1" in
 	-i|--interactive)
		CMD=$CMD_INTERACTIVE
		;;
	-t|--tag)
		CMD+=" -t $2"
		shift
		;;
	-n|--name)
		CMD+=" -n $2"
		shift
		;;
	-a|--arg)
		CMD+=" -a $2"
        if [ ! -z "$3" ] && [ "${3:0:1}" != "-" ]
        then
		    CMD+=" $3"
            shift
        fi
        shift
		;;
	*) echo "Option $1 not recognized!" 
		echo -e $USAGE
		exit 1;;
	esac
	shift
done

# Print info
echo -e "Running image: ${COLOR_INFO}$IMAGE${COLOR_DEFAULT}"

. $SCRIPTPATH/../images/$IMAGE/run.sh $CMD

