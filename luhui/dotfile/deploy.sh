#!/bin/sh

set -u


if [ "$(id -u)" == "0" ]
then
	echo "is root user! DONT'RUN'THIS'SCRIPT"
	exit 1
fi

THIS_DIR=$(dirname $(realpath ${0}))
TARGET_DIR=${HOME}
ITSELF=$(basename $(realpath ${0}))

cd ${THIS_DIR}


for i in *
do
	if [ "${i}" == "${ITSELF}" ]
	then
		echo "This is this script, skip"
	else
		echo "Processing: ${i}"
		stow -t ${TARGET_DIR} ${i}
	fi
done
