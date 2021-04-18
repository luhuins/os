#!/bin/sh

set -u
set -e

POS=$(dirname $(realpath ${0}))
cd ${POS}
dotfile_list=${POS}/.dotfile-list

cat ${dotfile_list} | while read line
do
    mkdir -pv $(dirname ${line})
    cp -v ${HOME}/${line} ${line}
done

git status



