#! /bin/bash

MUSICDIR=${HOME}/Music
TIMESTAMP=${MUSICDIR}/.normalize_volume_timestamp

if [[ ! -a $TIMESTAMP ]] ; then
    echo "ERROR: no timestamp file present."
    exit 1
fi

pid=$(pgrep rhythmbox)
if [[ "$pid" -ne "" ]] ; then
    echo "WARNING: please shut down rhythmbox before running this script."
    exit 1
fi

echo "normalizing files modified since $(stat -c '%y' ${TIMESTAMP})"

find ${MUSICDIR}/itunes -iname '*mp3' \
     -newer ${MUSICDIR}/.normalize_volume_timestamp \
     -exec nice mp3gain -r -k \{\} \;

touch $TIMESTAMP

exit 0
