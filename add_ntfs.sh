#!/bin/sh

fstab_add_win() {
	locale=${1:-"ru_RU.UTF8"}
	prefix=${2:-"/media"}
	blkid -g
	blkid -s LABEL -s TYPE 2>/dev/null | \
	sed -n s/'^\(\/dev\/[^ ]*\):[ ]*\(LABEL="\([^"]*\)"[ ]*\)\?TYPE="\([^"]*\).*/\1 \3 \4'/p | \
	while read devname label type; do
		if [ ! "$type" ] ; then
			type="$label"
			label=
		fi
		if [ ! "$label" ] ; then
			label=$(basename $devname)
		fi
		mnt_pnt="$prefix/$label"
		mkdir -p "${INSTALL_ROOT}$mnt_pnt" 2>/dev/null
		case "$type" in
			ntfs)
				echo "$devname	$mnt_pnt	ntfs-3g	defaults,noatime,gid=plugdev,fmask=117,dmask=007,locale=$locale	0	0" >> /etc/fstab
				mkdir -p $mnt_pnt && chown root:plugdev $mnt_pnt

			;;
		esac
	done
	return 0
}

echo "Usage sudo $(basename $0)"
fstab_add_win
