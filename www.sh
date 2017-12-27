#!/bin/sh
#
# Backup of WebSites v.2.1
# (c) Stanislav Rudenko, me [at] rooty [d0t] name
#
BASEDIR=$(dirname $0)

. "${BASEDIR}/.config"
. "${BASEDIR}/.www"

NOW=$(/bin/date +"%Y.%m.%d.%H.%M")

[ -n "${RUN_BEFORE_START}" ] && eval "${RUN_BEFORE_START}"

for ACTIVE_PROJECT in ${ACTIVE_PROJECTS}
 do

  wd=$(eval echo "\${PATH_WEBSITE_ROOT_${ACTIVE_PROJECT}}")

  if [ -z "$wd" ]
  then
    echo "I'll skip \"$wd\" because value is empty" 1>&2
    continue
  fi

  csn=$(echo ${ACTIVE_PROJECT} | tr '[:upper:]' '[:lower:]')

  echo ">>> Processing (${csn}):"

  if [ ! -d "$wd" ]
   then
    echo "I'll skip \"$wd\" due error... check this directory" 1>&2
    continue
  fi

  echo "${wd}"

  sx=$(eval echo "\${PATH_WEBSITE_EXCLUDE_${ACTIVE_PROJECT}}")

  exc_st=''

  if [ ! -z "$sx" ]
   then
    for ST in $sx
     do
      exc_st="${exc_st}--exclude ${ST} "
     done
  fi

  [ ! -d "${PATH_WWW_BACKUP}/${NOW}" ] && mkdir -p "${PATH_WWW_BACKUP}/${NOW}"

  ESTART=$(/bin/date +"%s")

  /usr/bin/nice -n 15 $PATH_BIN_TAR -cf - ${exc_st}-C ${wd} . | $PATH_BIN_ARCHIVE $ARCHIVE_OPTIONS -si ${PATH_WWW_BACKUP}/${NOW}/${csn}.7z >/dev/null

  EEND=$(/bin/date +"%s")

  echo "Elapsed time:" $(($EEND - $ESTART))

done

[ -n "${RUN_AT_THE_END}" ] && eval "${RUN_AT_THE_END}"

echo '>>> Cleaning old Backups'

/usr/bin/find ${PATH_WWW_BACKUP}/* -mtime +${OLD_BACKUPS}w -type d -exec /bin/rm -rvf {} \;

echo ">>> Operation took time from ${NOW} to `/bin/date +"%d.%m.%Y.%H.%M"`"

exit 0
