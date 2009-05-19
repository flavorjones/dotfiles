#! /bin/bash

MUSICDIR=${HOME}/Music
TIMESTAMP=${MUSICDIR}/.normalize_volume_timestamp

if [[ ! -a $TIMESTAMP ]] ; then
    echo "WARNING: no timestamp file present."
    sleep 2
    echo "continuing ..."
    newerarg=""
else
    echo "normalizing files modified since $(stat -c '%y' ${TIMESTAMP})"
    newerarg="-newer ${MUSICDIR}/.normalize_volume_timestamp"
fi


find ${MUSICDIR}/itunes -iname '*mp3' \
    $newerarg \
    -exec nice mp3gain -T -r -c \{\} \;

touch $TIMESTAMP

exit 0
