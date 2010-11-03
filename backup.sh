#!/bin/sh

BACKUP_SRC="/etc /var/spool/cron /root /home/nexor/workspace/scripts"
#empty for all bases backup
DB_LIST_PG=
DB_LIST_MY=

BACKUP_DST="/media/uVideo/home/nexor/backup"
RSYNC_DST="/media/uVideo/home/nexor/backup_secondary"

#empty = no rsync backup
RSYNC_DST_DAY="${RSYNC_DST}/day"
RSYNC_DST_MON="${RSYNC_DST}/month"

MAXBACKUPS=7

AUTH_MYSQL="-u root --password=pass"

EXT="tbz"
EXTSQL="sql.bz2"

LOGFILE="${BACKUP_DST}/backup.log"

log() {
	MSG="${1}"
	LEVEL="${2}"
	[ "${LEVEL}" = "4" ] && _mkdir $(dirname "${LOGFILE}") &&  echo > "${LOGFILE}"
	[ "${LEVEL}" != "1" ] && echo "${MSG}"
	[ "${LEVEL}" != "2" ] && echo "${MSG}" >> "${LOGFILE}"
}

# Exit with error message
die() {
	log " !!!ERROR: ${1}"
	exit 1
}

_mkdir() {
	[ -d "${1}" ] || mkdir -p "${1}" || die "can't create directory ${1}"
}

check()	{
	v=$(${1} --version 2>/dev/null)
	result=0
	[ ! "${v}" ] && result=1
	log "check ${1}: ${result}" 1
	return ${result}
}

rotate() {
	name="${1}"
	suff="${2}"
	i="${MAXBACKUPS}"
	rm -f "${name}-${i}.${suff}" 2>/dev/null
	while expr ${i} \> 1 > /dev/null  ; do
		j=$(expr ${i} - 1)
		src="${name}-${j}.${suff}"
		dst="${name}-${i}.${suff}"
		mv "$src" "$dst" 2>/dev/null
		i=${j}
	done
	echo $src
}

backup_mysql() {
	if check "mysql" ; then
		[ "${DB_LIST_MY}" ] || DB_LIST_MY=`echo "show databases;" | mysql "${AUTH_MYSQL}" 2>> "${LOGFILE}"| grep -v ^Database$`
			for DB_NAME in ${DB_LIST_MY} ; do
			name=$(rotate "${BACKUP_DST}/mysql/${DB_NAME}" "${EXTSQL}")
			_mkdir "$(dirname ${name})"
			log "mysql: ${DB_NAME}/ => ${name}"
			mysqldump "${AUTH_MYSQL}" "${DB_NAME}" 2>> "${LOGFILE}"| bzip2 -9c > "${name}"
		done
	fi
}

backup_pgsql() {
	if check "psql" ; then
		[ "${DB_LIST_PG}" ] || DB_LIST_PG=`psql -lA 2>> "${LOGFILE}"|sed 's/^\([^\|]*\).*/\1/'|tail -n +3|head -n -1|grep -v template[0-9]`
		for DB_NAME in ${DB_LIST_PG} ; do
			name=$(rotate "${BACKUP_DST}/pgsql/${DB_NAME}" "${EXTSQL}")
			_mkdir "$(dirname ${name})"
			log "pgsql: ${DB_NAME}/ => ${name}"
			pg_dump ${DB_NAME} 2>> "${LOGFILE}"| bzip2 -9c > ${name}
		done
	fi
}

backup_files() {
	_mkdir "${BACKUP_DST}"
	for dir in ${BACKUP_SRC} ; do
		archname=`basename ${dir}`
		name=$(rotate ${BACKUP_DST}/${archname} ${EXT})
		log "files: ${dir}/ => ${name}"
		tar -p -j -cf "${name}" ${dir}/ 2>> "${LOGFILE}"
#		log "$result"
	done
}

rsync_to() {
	if [ "${RSYNC_DST_DAY}" ] ; then
		_mkdir "${RSYNC_DST_DAY}"
		rsync -r ${BACKUP_DST}/ ${RSYNC_DST_DAY} 2>> "${LOGFILE}"
	fi
}

rsync_reserve() {
	if [ "${RSYNC_DST_MON}" ] ; then
		_mkdir "${RSYNC_DST_MON}"
		rsync -r ${BACKUP_DST}/ ${RSYNC_DST_MON} 2>> "${LOGFILE}"
	fi
}

#main
case "$1" in
	files)
		log "backup files" 4
		backup_files
		rsync_to
	;;
	mysql)
		log "backup mysql" 4
		backup_mysql
		rsync_to
	;;
	pgsql)
		log "backup pgsql" 4
		backup_pgsql
#		rsync_to
	;;
	reserve)
		log "copying backup to reserve" 4
		rsync_reserve
	;;
	all)
		log "backup all" 4
		backup_mysql
		backup_pgsql
		backup_files
		rsync_to
	;;
	*)
		log "Usage: backup {files|mysql|pgsql|all|reserve}" 2
		exit 1
esac

log "stop backup"
