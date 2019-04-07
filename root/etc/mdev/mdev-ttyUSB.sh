#!/bin/sh
while [ -z "$(mount | grep '/tmp ')" ];do sleep 1;done
ENABLE_LOG=1
LOG="/tmp/ttyUSB.log"
LOG2="/tmp/mdev.log"
private_rule_file="/etc/mdev/ttyUSB-private.rules"
#
loginfo() {
[ -n "$2" ] && logfile=$LOG2 || logfile=$LOG
OUT=$1
logleft="[$ACTION] $(date +'%H:%M:%S') [$MDEV]"
if [ "$ENABLE_LOG" == "1" ];then
	echo "$logleft $OUT" >> $logfile
else
	echo "$logleft $OUT"
fi
}
#
private_link() {
pdev=""
if [ "$2" == "$serial" ];then
	if [ "$3" == "$bInterfaceNumber" ];then
		pdev=$1
	else
		pdev=$1
	fi
elif [ "$idProduct" == "2303" -a "$2" == "PL2303" ];then
	pdev=$1
fi
if [ -n "$pdev" ];then
	if [ ! -e /dev/serial/$pdev ];then
		loginfo "add link: /dev/serial/$pdev" 2
		ln -sf ../$MDEV /dev/serial/$pdev
	else
		loginfo "link: /dev/serial/$pdev already exist" 2
	fi
fi
}
#
do_private_links() {
while read text;do
	line=$(echo $text | grep -v "^#")
	[ -n "$line" ] && private_link $line
done < $private_rule_file
}
#
if [ "$SUBSYSTEM" == "tty" ];then
case "$ACTION" in
	add)
	[ -n "$DEVPATH" ] && SYSDEVPATH=/sys$DEVPATH || exit 0
	sdev=""
	s2dev=""
	interface=$(cat $SYSDEVPATH/../../../interface)
	product=$(cat $SYSDEVPATH/../../../../product)
	serial=$(cat $SYSDEVPATH/../../../../serial | tr ' ' '_')
	idVendor=$(cat $SYSDEVPATH/../../../../idVendor)
	idProduct=$(cat $SYSDEVPATH/../../../../idProduct)
	manufacturer=$(cat $SYSDEVPATH/../../../../manufacturer)
	bInterfaceNumber=$(cat $SYSDEVPATH/../../../bInterfaceNumber)
	loginfo "$SYSDEVPATH"
	[ -n "$manufacturer" ] && loginfo "Manufacturer: $manufacturer"
	[ -n "$product" ] && loginfo "Product: $product"
	[ -n "$interface" ] && loginfo "Interface: $interface"
	[ -n "$idVendor" ] && loginfo "idVendor: $idVendor"
	[ -n "$idProduct" ] && loginfo "idProduct: $idProduct"
	[ -n "$serial" ] && loginfo "Serial: $serial"
	[ -n "$bInterfaceNumber" ] && loginfo "Interface Number: $bInterfaceNumber"
	if [ -z "$serial" ];then
		# chips without serial
		[ -n "$interface" ] && sdev=$(echo $interface | tr " " "_")"_"
		[ -z "$sdev" -a -n "$product" ] && sdev=$(echo $product | tr " " "_")"_"
		[ -z "$sdev" -a -n "$manufacturer" ] && sdev=$(echo $manufacturer | tr " " "_" | tr -d ".")"_"
		[ -z "$sdev" ] && sdev=$idVendor"_"$idProduct"_"
		sdev=$sdev$MDEV
		[ "$idProduct" == "2303" ] && s2dev="PL"$idProduct"_"$MDEV
	else
		# chips with serial
		[ -n "$interface" ] && sdev=$(echo $interface | tr " " "_")"_"
		[ -z "$sdev" -a -n "$product" ] && sdev=$(echo $product | tr " " "_")"_"
		[ -z "$sdev" -a -n "$manufacturer" ] && sdev=$(echo $manufacturer | tr " " "_")"_"
		[ -z "$sdev" ] && sdev=$idVendor"_"$idProduct"_"
		sdev=$sdev$serial"_"$bInterfaceNumber
		s2dev=$serial"_"$bInterfaceNumber
	fi
	[ ! -d /dev/serial ] && mkdir -p /dev/serial
	loginfo "add link: /dev/serial/$sdev" 2
	ln -sf ../$MDEV /dev/serial/$sdev
	if [ -n "$s2dev" ];then
		loginfo "add link: /dev/serial/$s2dev" 2
		ln -sf ../$MDEV /dev/serial/$s2dev
	fi
	[ -f $private_rule_file ] && do_private_links
	;;
	remove)
	[ -n "$DEVPATH" ] && SYSDEVPATH=/sys$DEVPATH
	loginfo "$SYSDEVPATH"
	for link in $(ls /dev/serial);do
		if [ "$(readlink /dev/serial/$link)" == "../$MDEV" ];then
			loginfo "delete link: /dev/serial/$link" 2
			rm -f /dev/serial/$link
		fi
	done
	if [ -z "$(ls /dev/serial)" ];then
		loginfo "delete dir: /dev/serial" 2
		rm -rf /dev/serial
	fi
	;;
esac
fi
exit 0
