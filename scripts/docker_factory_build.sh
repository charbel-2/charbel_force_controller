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

IMAGES=$(find $HOME/utils/docker_factory/images -name Dockerfile | cut -d "/" -f7- | rev | cut -d "/" -f2- | rev )

USAGE="Usage: \n docker_factory_build IMAGE_NAME [OPTIONS...] 
\n\n
Available IMAGE_NAMEs: [${COLOR_INFO}$IMAGES${COLOR_RESET}]
\n\n
Help Options:
\n
-h,--help \tShow help options
\n\n
Application Options:
\n 
-t,--tag \tImage tag [default=latest], example: -t latest
\n 
-r,--registry \tDocker registry to use for the push, example: -r internal-registry:5000
\n
-nc,--no-cache \tDisable the use of cached layers when building an image
"

# Default
IMAGE=
TAG=latest
REGISTRY=
NOCACHE=

if [[ ( $1 == "--help") ||  $1 == "-h" ]] 
then 
	echo -e $USAGE
	exit 0
fi

# Read image
IMAGE="$1"

# Check if image name is provided in command line
if [ -z "$IMAGE" ]; then
	echo -e "${COLOR_WARN}"No image name specified! Please provide the name of the image to build."${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi

shift

# Check whether image Dockerfile exists
if [ -f "$SCRIPTPATH/../images/$IMAGE/Dockerfile" ]
then 
	echo -e "${COLOR_INFO}Selected image: $IMAGE${COLOR_RESET}"
else
	echo -e "${COLOR_WARN}"Wrong image option!"${COLOR_RESET}"
	echo -e $USAGE
	exit 1
fi

# The 'other_args' variable will store any other arguments
OTHER_ARGS=""

while [ -n "$1" ]; do # while loop starts
	case "$1" in
	-t|--tag)
		TAG="$2"
		shift
		;;
	-r|--registry)
		REGISTRY="$2"
		shift
		;;
	-nc|--no-cache)
		NOCACHE=--no-cache
		;;
	*)
		# If the argument is not a known one, add it to OTHER_ARGS
		OTHER_ARGS+="$1 "
		;;
	esac
	shift
done

if [ -f "$SCRIPTPATH/../images/$IMAGE/docker_run.cfg" ]
then 
	source $SCRIPTPATH/../images/$IMAGE/docker_run.cfg	
fi


# Print info
echo -e "${COLOR_INFO}Building image: $IMAGE${COLOR_RESET}"

docker build \
	--tag $IMAGE:$TAG \
	--build-arg USERNAME=$USERNAME \
	--build-arg USER_UID=$USER_UID \
	--build-arg WORKSPACE=$WORKSPACE \
	--build-arg REGISTRY=$REGISTRY \
	--build-arg IMAGE=$IMAGE \
	--build-arg TAG=$TAG \
	--ssh default=$SSH_AUTH_SOCK \
	-f $SCRIPTPATH/../images/$IMAGE/Dockerfile \
	--network=host \
	$NOCACHE \
	$OTHER_ARGS .

# Prune <none> images if created during the building
docker image prune -f

# push if registry is available
if [[ ! -z $REGISTRY ]]
then
	docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:$TAG
	docker push $REGISTRY/$IMAGE:$TAG
fi

