#!/bin/sh
#
ENABLE_LOG=1
LOG="/tmp/mdev.log"
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
#
if [ "$ACTION" == "add" -a "$MDEV" == "mmcblk0p1" ];then
	if [ -z "$(mount | grep $MDEV | grep /boot)" ];then
		loginfo "mounting $MDEV to /boot"
		mount -t auto /dev/$MDEV /boot
	else
		loginfo "/dev/$MDEV already mounted - not mounting again"
	fi
fi
exit 0
