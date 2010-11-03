#!/bin/sh

REP=/home/nexor/rep
MNT_ROOT=/mnt

DIST_NAME="karmic"
SECTION="main"
USERNAME="nexor"
COMPNAME="buben3000"

#./make_repo.sh - $REP
#exit
umount ${MNT_ROOT}/proc
umount ${MNT_ROOT}/sys
umount ${MNT_ROOT}/cdrom
umount  /dev/sdb4
mount /dev/sdb4 /mnt

#debootstrap "${DIST_NAME}" "${MNT_ROOT}" file://$REP

#fstab
echo "proc ${MNT_ROOT}/proc proc defaults 0 0
sysfs ${MNT_ROOT}/sys sysfs defaults 0 0
" >> ${MNT_ROOT}/etc/fstab


#apt
[ -d "${MNT_ROOT}/media/cdrom" ] || mkdir "${MNT_ROOT}/media/cdrom"
[ -d "${MNT_ROOT}/cdrom" ] || ln -s "media/cdrom" "${MNT_ROOT}/cdrom"

echo "deb file:/cdrom ${DIST_NAME} ${SECTION}" > "${MNT_ROOT}/etc/apt/sources.list"

echo 'APT::Authentication::TrustCDROM "true";' > "${MNT_ROOT}/etc/apt/apt.conf.d/00trustcdrom"
echo 'APT
{
    Install-Recommends "false";
    Install-Suggests "false";
};
' > "${MNT_ROOT}/etc/apt/apt.conf.d/99norecom"

echo '
127.0.0.1 localhost
127.0.0.1 '${COMPNAME}'
' > "${MNT_ROOT}/etc/hosts"

echo "${COMPNAME}" > "${MNT_ROOT}/etc/hostname"

#init script
echo '#!/bin/sh
cd $(dirname $0)
cat "/media/cdrom/public.key" | apt-key add -
apt-get -y update
apt-get -y --allow-unauthenticated install \
locales language-pack-ru util-linux-locales \
perl gnupg apt-utils sudo dialog \
policykit hal fuse-utils fuse-module

#configs
echo "%sudo ALL=NOPASSWD: ALL" >> /etc/sudoers
echo "LANG=\"ru_RU.UTF-8\"" > /etc/default/locale

sed "s/CODESET=.*/CODESET=\"CyrSlav\"/
s/XKBLAYOUT=.*/XKBLAYOUT=\"us,ru\"/
s/XKBVARIANT=.*/XKBVARIANT=\",\"/
s/XKBOPTIONS=.*/XKBOPTIONS=\"grp:caps_toggle,lv3:ralt_switch,compose:lwin,grp_led:scroll\"/" -i /etc/default/console-setup

#dpkg-reconfigure console-setup

aptitude
echo " adding user '${USERNAME}'"
useradd --user-group --create-home \
	--shell /bin/bash \
	--groups sudo,audio,video,plugdev,users,fuse,polkituser \
	"'${USERNAME}'"
passwd "'${USERNAME}'"
echo "Type exit for return to host system"
sh
' > "${MNT_ROOT}/root/install.sh"
chmod +x "${MNT_ROOT}/root/install.sh"

#temporary mounts
mount proc ${MNT_ROOT}/proc -t proc
mount sysfs ${MNT_ROOT}/sys -t sysfs
#mount -o bind "${REP}" "${MNT_ROOT}/cdrom"
#cp -raL "${REP}" "${MNT_ROOT}/cdrom"

chroot "${MNT_ROOT}" /bin/sh /root/install.sh

umount ${MNT_ROOT}/proc
umount ${MNT_ROOT}/sys
umount ${MNT_ROOT}/cdrom
