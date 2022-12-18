#!/bin/sh
CRTSCRIPT=`readlink -f $0`
BASEDIR=${CRTSCRIPT%/*}

if [ $# -lt 1 ]
then
    echo "Usage: sh $0 <action> <codec>"
    exit 1
else
    ACTION=$1
    CODEC=$2
    DIRECTORY_RIP=/media/rip/
    if [ -n $CODEC ]
    then
        python3 /usr/local/bin/convert_audio.py $DIRECTORY_RIP $CODEC
    else
        echo "$1: Valid options: rip | encode ">&2
        exit 1
    fi
esac
fi
