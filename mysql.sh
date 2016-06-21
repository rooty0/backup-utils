#!/bin/sh
#
# Backup of MySQL v.1.2
# (c) Stanislav Rudenko, me [at] rooty [d0t] name
#

BASEDIR=$(dirname $0)

. "${BASEDIR}/.config"

NOW=$(/bin/date +"%Y.%m.%d.%H.%M")
DBS="$($PATH_BIN_MYSQL --defaults-file=${MYSQL_DEF_FILE} -Bse 'show databases')"

if [ -z "${DBS}" ]; then echo "!!!DATABASE LIST IS EMPTY!!!"; exit 1; fi;

[ ! -d "${PATH_MYSQL_BACKUP}/${NOW}" ] && mkdir -p "${PATH_MYSQL_BACKUP}/${NOW}"

echo '>>> Creating Backup of databases'

for DB in ${DBS}
 do

  for DB_EXCEPTION in ${BACKUP_DB_EXCEPTIONS}
   do
    if [ "${DB}" = "${DB_EXCEPTION}" ]; then continue 2; fi;
  done

  echo "] Processing database \"${DB}\""

  ${PATH_BIN_MYSQLDUMP} --defaults-file=${MYSQL_DEF_FILE} -f ${DB} > ${PATH_MYSQL_BACKUP}/${NOW}/mydb_backup_${DB}_database.sql

done

echo '>>> Cleaning old Backups'

/usr/bin/find ${PATH_MYSQL_BACKUP} -ctime +${OLD_BACKUPS}w -type d -exec /bin/rm -rvf {} \;

if [ ${COMPRESS_FILES} = "yes" ]
 then

  echo ">>> Creating an archive using ${PATH_BIN_ARCHIVE}"

  for DB_FILE in $(ls -1 "${PATH_MYSQL_BACKUP}/${NOW}" | xargs)
   do

    /usr/bin/nice -n 15 ${PATH_BIN_ARCHIVE} ${ARCHIVE_OPTIONS} "${PATH_MYSQL_BACKUP}/${NOW}/${DB_FILE}.7z" "${PATH_MYSQL_BACKUP}/${NOW}/${DB_FILE}" >/dev/null

    if [ $? -eq 0 ]
     then
      rm -rf ${PATH_MYSQL_BACKUP}/${NOW}/${DB_FILE}
     else
      echo "!!!!! SOMETHING WRONG HAPPENS DUE COMPRESS FILE ${DB_FILE} !!!!!"
    fi

  done

fi

echo ">>> Operation took time from ${NOW} to `/bin/date +"%d.%m.%Y.%H.%M"`"

exit 0
