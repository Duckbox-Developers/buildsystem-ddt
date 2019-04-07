#!/bin/sh
while [ -z "$(mount | grep '/dev ')" ];do sleep 1;done
MODALIAS=$1
ENABLE_LOG=1
LOG="/dev/.mdev/modalias.log"
#
loginfo()
{
OUT=$1
logleft="[$ACTION] $(date +'%H:%M:%S') [$MDEV]"
if [ "$ENABLE_LOG" == "1" ];then
	echo "$logleft $OUT" >> $LOG
else
	echo "$logleft $OUT"
fi
}
# load modul
load_modul() {
modul=""
[ "$1" == "v067B" ] && modul="pl2303"
[ "$1" == "v0403" ] && modul="ftdi_sio"
if [ -n "$modul" ];then
	if [ ! -e /sys/module/$modul ];then
		insmod $modul
		loginfo "loading "$modul".ko"
	else
		loginfo $modul".ko already loaded"
	fi
fi
}
#
if [ -n "$MODALIAS" ];then
	[ ! -d /dev/.mdev ] && mkdir -p /dev/.mdev
	mod=$(echo ${MODALIAS:4:5})
	if [ "$mod" == "v067B" -o "$mod" == "v0403" ];then
		loginfo $MODALIAS
		load_modul $mod
	fi
fi
exit 0
