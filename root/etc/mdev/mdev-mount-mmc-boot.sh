#!/bin/sh
#
ENABLE_LOG=1
LOG="/tmp/mdev.log"

model=`cat /proc/stb/info/model`
[ -e /proc/stb/info/vumodel ] && vumodel=`cat /proc/stb/info/vumodel`
[ "$model" == "dm8000" ] && [ "$vumodel" == "solo4k" ] && model=$vumodel
[ "$model" == "dm8000" ] && [ "$vumodel" == "duo4k" ] && model=$vumodel
[ "$model" == "dm8000" ] && [ "$vumodel" == "ultimo4k" ] && model=$vumodel
[ "$model" == "dm8000" ] && [ "$vumodel" == "zero4k" ] && model=$vumodel

case $model in
	zero4k) BOOTPART=mmcblk0p4;;
	duo4k) BOOTPART=mmcblk0p6;;
	*) BOOTPART=mmcblk0p1;;
esac

loginfo() {
	OUT=$1
	logleft="[$ACTION] $(date +'%H:%M:%S') [$MDEV]"
	if [ "$ENABLE_LOG" == "1" ];then
		echo "$logleft $OUT" >> $LOG
	else
		echo "$logleft $OUT"
	fi
}

if [ "$ACTION" == "add" -a "$MDEV" == "$BOOTPART" ];then
	if [ -z "$(mount | grep $MDEV | grep /boot)" ];then
		loginfo "mounting $MDEV to /boot"
		mount -t auto /dev/$MDEV /boot
	else
		loginfo "/dev/$MDEV already mounted - not mounting again"
	fi
fi
exit 0
