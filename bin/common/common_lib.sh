#!/bin/bash

# Copyright 2018 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/tmp/group
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

function enable_debugging() {
    if [[ ${DEBUG:-false} == "true" ]]
    then
        echo "Turning Debugging On"
        export PS4='+(${BASH_SOURCE}:${LINENO})> ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        set -x
    fi
}

function ose_hack() {
    export USER_ID=$(id -u)
    export GROUP_ID=$(id -g)
    envsubst < /opt/cpm/conf/passwd.template > /tmp/passwd
    envsubst < /opt/cpm/conf/group.template > /tmp/group
}

function env_check_err() {
    env=$(echo $1)
    if [[ -z ${env:+x} ]]
    then
        echo_err "${env?} environment variable is not set, aborting.."
        exit 1
    fi
}

function env_check_warn() {
    env=$(echo $1)
    if [[ -z ${env:+x} ]]
    then
        echo_warn "${env?} environment variable is not set.."
    fi
}

function echo_err() {
    echo -e "${RED?}$(date) ERROR: ${1?}${RESET?}"
}

function echo_info() {
    echo -e "${GREEN?}$(date) INFO: ${1?}${RESET?}"
}

function echo_warn() {
    echo -e "${YELLOW?}$(date) WARN: ${1?}${RESET?}"
}
