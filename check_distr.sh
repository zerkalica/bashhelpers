#!/bin/sh

DISTNAME='maverick'
NEWDIST='natty'

cat /etc/apt/sources.list | \
while read str ; do
	url=`echo "$str" | sed -n "s/[# ]*deb \([^ ]*\) $DISTNAME\([[:alpha:][:graph:]]*\) \(.*\)/\1/gp"`
	new_str=""
	if [ "$url" ] ; then
		if wget -q -S "$url/dists/$NEWDIST/Release" -O /dev/null ; then
			new_str=`echo "$str" | sed "s/$DISTNAME/$NEWDIST/g"`
		fi
		
	fi

	if [ "$new_str" ] ; then
		str="$new_str"
	else
		[ "$url" ] && str="$str"
	fi

	echo $str
	echo "$str" >> ./sources.new.list
done

#cat /etc/apt/sources.list | sed "s/[# ]*deb \([^ ]*\) $DISTNAME\([[:alpha:][:graph:]]*\) \(.*\)/\1 $NEWDIST\2 \3/g"
