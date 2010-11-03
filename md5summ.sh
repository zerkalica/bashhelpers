#!/bin/sh
CDIR=`pwd`
cd $1
find . -type f -exec md5sum {} \; | grep -v ' ./DEBIAN/' | sed 's/\s*\.\// /g' > $CDIR/md5sums
cd $CDIR
