#!/bin/sh
while [ -z "$(mount | grep '/dev ')" ];do sleep 1;done
[ "$SHLVL" != "2" ] && exit 0
ENABLE_LOG=1
LOG="/dev/.mdev/mdev-events.log"
#
loginfo()
{
OUT=$1
logleft="[$ACTION] $(date +'%H:%M:%S') [$MDEV]"
if [ "$ENABLE_LOG" == "1" ];then
	echo "$logleft $OUT" >> $LOG
fi
}
env_log() {
	if [ -n "$(echo $MDEV | grep $1)" ];then
		env >> /dev/.mdev/$MDEV.log
		echo "" >>  /dev/.mdev/$MDEV.log
	fi
}
#
	[ ! -d /dev/.mdev ] && mkdir -p /dev/.mdev
	loginfo "SHLVL: $SHLVL"
	#env >> $LOG
exit 0
