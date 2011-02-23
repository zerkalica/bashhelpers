#!/bin/sh
td=`pwd`
mkdir -p $2
cd $2
gunzip < $1 | cpio -i --make-directories
