#!/bin/sh

SRC_DIR="$1"
DEST_DIR="$2"
PGP_NAME=${3:-"Stefan Zerkalica"}
PUBLIC_KEY="public.key"
SECTION="main"

SECTION_DIR="${DEST_DIR}/pool"

ARCH=$(dpkg --print-architecture)
DIST_NAME=$(lsb_release -cs)
VERSION=$(lsb_release -rs)
LABEL=$(lsb_release -is)
DESC=$(lsb_release -ds)

DIST="dists/${DIST_NAME}"
PKG_DIR="${DIST}/${SECTION}/binary-${ARCH}"
PKG_FILE="${PKG_DIR}/Packages"

putlog()
{
	echo "${1}"
}

die()
{
	putlog " !!!ERROR: ${1}"
	exit 1
}

_mkdir()
{
	[ -d "${1}" ] || mkdir -p "${1}" || die "can't create directory ${1}"
}


if [ ! "${DEST_DIR}" ] ; then
	putlog "Repository from debs creator
Usage: $0 path_to_debs destination_repository_path
If path_to_debs = - , only recreat Repease, Packages and keys in repository
"
	exit 0
fi

if [ "${SRC_DIR}" != "-" ] ; then
	putlog "Copying debs from ${SRC_DIR} to ${SECTION_DIR}"
	_mkdir "$SECTION_DIR"
	cp -ra ${SRC_DIR}/* ${SECTION_DIR}/
fi

cd "${DEST_DIR}" || die "can't cd to ${DEST_DIR}"

_mkdir "$PKG_DIR"

putlog "Making list file ${PKG_FILE}"
apt-ftparchive packages pool > "${PKG_FILE}"
cat "${PKG_FILE}" | gzip -9c > "${PKG_FILE}.gz"


putlog "Making release file ${DIST}/Release"
APT_CFG=$(mktemp /tmp/apt.conf.XXXXXXXXXX)
cat > "${APT_CFG}" << EOF
APT::FTPArchive::Release {
	Origin "${LABEL}";
	Label "${LABEL}";
	Suite "${DIST_NAME}";
	Codename "${DIST_NAME}";
	Architectures "${ARCH}";
	Components "${SECTION}";
	Description "${DESC}";
};
EOF
apt-ftparchive -c "${APT_CFG}" release ${DIST}/ > "${DIST}/Release"
rm -f "${APT_CFG}"

putlog "Signing repository ${DIST}/Release.gpg and ${PUBLIC_KEY}"
[ -e "${DIST}/Release.gpg" ] && rm -f "${DIST}/Release.gpg"
gpg -u "${PGP_NAME}" -bao "${DIST}/Release.gpg" "${DIST}/Release"
gpg --export -a "${PGP_NAME}" > "${PUBLIC_KEY}"

putlog "Making ${DEST_DIR}/.disk info for CD-ROMS"
DISK_DIR="${DEST_DIR}/.disk"
[ -d "${DISK_DIR}" ] || mkdir -p "${DISK_DIR}"
echo "${LABEL} $(date +%Y-%m-%d)" > "${DISK_DIR}/info"
echo "${SECTION}" > "${DISK_DIR}/base_section"

README="
Examples:
CDROM install:
echo \"deb file:/media/cdrom ${DIST_NAME} ${SECTION}\" >> /etc/apt/sources.list
cat /media/cdrom/${PUBLIC_KEY} -O- | sudo apt-key add -

Internet install:
echo \"sudo deb http://your_site/repo_root ${DIST_NAME} ${SECTION}\" >> /etc/apt/sources.list
wget -q \"http://your_site/repo_root/${PUBLIC_KEY}\" -O- | sudo apt-key add -"


echo "Done.
Repo: ${DEST_DIR}
Public key: ${DEST_DIR}/${PUBLIC_KEY}
${README}
"
RDM_FILE="${DEST_DIR}/readme.txt"

[ -e "${RDM_FILE}" ] || echo "${README}" > "${RDM_FILE}"

