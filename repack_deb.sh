#!/bin/sh
clear
TMP_DEB=./${1}_data
if [ -d ${TMP_DEB}/DEBIAN ] ; then
    echo "Creating deb package..."
    mv ${1} ${1}.bak
    sudo chown -R root:root ${TMP_DEB}
    dpkg -b ${TMP_DEB} $1
    rm -rf ${TMP_DEB}
    exit 0
fi
echo "Unpacking DEB package in ${TMP_DEB}"
mkdir -p ${TMP_DEB}/DEBIAN

mkdir -p ${TMP_DEB}/DEBIAN && dpkg -x $1 ${TMP_DEB} && dpkg -e $1 ${TMP_DEB}/DEBIAN

dpkg -b ${TMP_DEB} $1
