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

#Clean docker stopped containers, volumes and images
# see: http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images and https://github.com/chadoe/docker-cleanup-volumes

# Stopped containers 
docker rm $(docker ps -qa --no-trunc --filter "status=exited") 2> /dev/null
# Volumes
docker volume rm $(docker volume ls -qf dangling=true) 2> /dev/null
# Images
docker rmi $(docker images --filter "dangling=true" -q --no-trunc) 2> /dev/null
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }') 2> /dev/null
# Registry
docker exec $(docker ps -f "name=registry" --format "{{.ID}}") registry garbage-collect /etc/docker/registry/config.yml 2> /dev/null
# Unused Cache 
docker builder prune -f
