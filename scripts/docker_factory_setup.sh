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

USAGE="
docker_factory tool \n
Docker factory is a tool which simplify and speed up recurrent docker operations and allows to have a single storage for the images. You have different aliases to interact with the tool:

- docker_factory_build: to build docker images.
- docker_factory_clean: to clean pending docker images or <none> images
- docker_factory_run  : to run docker applications
- docker_factory_connect  : to open a new bash of an existing image container

use the '-h' option after such aliases to see how they work
"

alias docker_factory_help="echo -e '$USAGE'"
alias docker_factory_build="cd $HOME/utils/docker_factory && ./scripts/docker_factory_build.sh"
alias docker_factory_clean=". $HOME/utils/docker_factory/scripts/docker_factory_clean.sh"
alias docker_factory_run="cd $HOME/utils/docker_factory && ./scripts/docker_factory_run.sh"
alias docker_factory_connect="cd $HOME/utils/docker_factory && ./scripts/docker_factory_connect.sh"

alias_completions() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Autocompletion for docker file

    case "${prev}" in
        docker_factory_build)
            DOCKER_FACTORY_BUILD_DIRS="$(find $HOME/utils/docker_factory/images -name Dockerfile | cut -d "/" -f7- | rev | cut -d "/" -f2- | rev )"
            opts="$DOCKER_FACTORY_BUILD_DIRS"
            ;;
        docker_factory_run)
            DOCKER_FACTORY_RUN_DIRS="$(find $HOME/utils/docker_factory/images -name run.sh | cut -d "/" -f7- | rev | cut -d "/" -f2- | rev )"
            opts="$DOCKER_FACTORY_RUN_DIRS"
            ;;
        docker_factory_connect)
            CONTAINERS=$(docker ps --format "{{.Names}}")
            opts="$CONTAINERS"
            ;;
        *)
            opts=""
            ;;
    esac

    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
}

complete -F alias_completions docker_factory_build
complete -F alias_completions docker_factory_run
complete -F alias_completions docker_factory_connect