#!/bin/sh
td=`pwd`
mkdir -p $2
cd $2
gunzip < ${td}/$1 | cpio -i --make-directories
