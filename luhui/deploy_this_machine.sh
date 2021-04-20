#!/bin/sh

set -e
set -u

CWD=$(pwd)

#
# root user:
#

export GUIX_SOURCE_GIT_REPO="/srv/code/git/guix"

# update guix source code
cd ${GUIX_SOURCE_GIT_REPO}/
git pull gnu master
git fetch gnu keyring:keyring
cd ${CWD}/

# update guix
guix pull --url=${GUIX_SOURCE_GIT_REPO} --branch=master 
hash guix

# need load path
export GUIX_USER_CNFIG_GIT_REPO="/srv/code/git/linux-os"
export GUIX_BUILD_OPTIONS="-L${GUIX_USER_CNFIG_GIT_REPO}"
# update guix system
guix system reconfigure /etc/config.scm 


#
# normal users:
#
cd /home
for i in *
do
	if [ -e ${i}/.deploy_this_user.sh ]
	then
		su - ${i} -c "/bin/sh ./.deploy_this_user.sh"
	else
		echo "user ${i} not have deploy_this_user.sh"
	fi
done
