#!/bin/sh


source ${HOME}/.bash_profile

set -e
set -u

CWD=$(pwd)

export GUIX_SOURCE_GIT_REPO="/srv/code/git/guix"
guix pull --url="${GUIX_SOURCE_GIT_REPO}" --branch=master
hash guix

export GUIX_USER_CONFIG_GIT_REPO="/srv/code/git/linux-os"
export GUIX_BUILD_OPTIONS="-L${GUIX_USER_CONFIG_GIT_REPO}"
export USER_NAME=$(id -n -u)

cd ${GUIX_USER_CONFIG_GIT_REPO}/luhui/manifests/
guix build -m ${USER_NAME}.scm
guix package -m ${USER_NAME}.scm
cd ${CWD}

cd ${GUIX_USER_CONFIG_GIT_REPO}/luhui/dotfile/
sh deploy.sh
cd ${CWD}
