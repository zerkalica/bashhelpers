#!/bin/sh

src_debs="/var/cache/apt/archives"

resync_cache()
{
	pkg_list="$1"
    echo "Removing non-installed packages"
    apt-get autoclean
    apt-get autoremove
    echo "Really removing non-installed packages"
    ls $src_debs/*.deb |
    while read i ; do 
        pkgname=`dpkg -f $i Package`
		pkginstalled=`echo $pkg_list | grep $pkgname`
	if [ -z "$pkginstalled" ] ; then
	    echo "Delete $i"
	    rm $i
	fi
    done
    echo "Downloading installed packages into cache (if no)"
    apt-get -dy --force-yes --reinstall install $pkg_list
}

# main()
apt-get update
apt-get dist-upgrade -y
pkg_list=$(dpkg -l|sed -n 's/^ii[ ]*\([^ ]*\).*/\1/p')
resync_cache "${pkg_list}"


