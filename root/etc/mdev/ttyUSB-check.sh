#!/bin/sh
#
while [ -z "$(mount | grep '/dev ')" ];do sleep 1;done
ENABLE_LOG=1
LOG="/dev/.mdev/modalias.log"
MODFILE="/etc/modules.extra"
ftdi_bus=0
pl2303_bus=0
ftdi_mod=0
pl2303_mod=0
#
loginfo()
{
OUT=$1
logleft="[CHECK] $(date +'%H:%M:%S') "
if [ "$ENABLE_LOG" == "1" ];then
	echo "$logleft $OUT" >> $LOG
else
	echo "$logleft $OUT"
fi
}
#
usb_bus_check() {
for a in $(cat /sys/bus/usb/devices/*/*/modalias | grep v0[46][07][3B]);do
	b=$(echo ${a:4:10})
	[ -n "$(echo $b | grep '0403')" ] && mod=ftdi_sio && ftdi_bus=1
	[ -n "$(echo $b | grep '067B')" ] && mod=pl2303 && pl2303_bus=1
	loginfo "detect modalias: $b > $mod needed"
done
loginfo "detect on USB bus > FTDI: $ftdi_bus PL2303: $pl2303_bus"
}
#
mod_file_check() {
if [ -f $MODFILE ];then
	while read text;do
		[ -n "$(echo $text | grep 'ftdi_sio')" ] && ftdi_mod=1
		[ -n "$(echo $text | grep 'pl2303')" ] && pl2303_mod=1
	done < $MODFILE
fi
}
#
adapter_reset() {
loginfo "reset-filter: $1 cmd: $2"
p=/sys/bus/usb/devices/*/*/idVendor
for a in $(ls $p);do
	if [ -n "$(cat $a | grep $1)" ];then
		#loginfo $a
		len=$((${#a}-9))
		b=$(echo ${a:0:len})
		#loginfo $b
		loginfo "$a: $(cat $a)"
		echo $2 > $b/authorized
		loginfo "$(ls $b/authorized): $(cat $b/authorized)"
	fi
done
}
#
mod_file_check
[ "$ftdi_mod" == "1" -a "$pl2303_mod" == "1" ] && exit 0 # no action
#
sleep 2
[ ! -d /dev/.mdev ] && mkdir -p /dev/.mdev
#
usb_bus_check
[ "$ftdi_bus" == "0" -a "$pl2303_bus" == "0" ] && exit 0 # no action
#
loginfo "entries in modules.extra > ftdi_sio: $ftdi_mod pl2303: $pl2303_mod"
#
[ -e /sys/module/ftdi_sio ] && loginfo "module ftdi_sio already loaded"
[ -e /sys/module/pl2303 ] && loginfo "module pl2303 already loaded"
#
if [ "$ftdi_bus" == "1" -a "$pl2303_bus" == "1" -a "$ftdi_mod" == "0" -a "$pl2303_mod" == "0" -a ! -e /sys/module/ftdi_sio -a ! -e /sys/module/pl2303 ];then
	filter="0[46][07][3b]"
elif [ "$ftdi_bus" == "1" -a "$ftdi_mod" == "0" -a ! -e /sys/module/ftdi_sio ];then
	filter="0403"
elif [ "$pl2303_bus" == "1" -a "$pl2303_mod" == "0" -a ! -e /sys/module/pl2303 ];then
	filter="067b"
else
	exit 0
fi
adapter_reset $filter 0
adapter_reset $filter 1
exit 0
