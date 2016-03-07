#
# checkroot.sh	Check to root file system.
#
# Version:	@(#)checkroot.sh  2.85-23  29-Jul-2004  miquels@cistron.nl
#
# chkconfig: S 10 0
#

SULOGIN=no
VERBOSE=yes
[ -f /etc/default/rcS ] && . /etc/default/rcS

PATH=/lib/init:/bin:/sbin:/usr/bin:/usr/sbin

#
#	Helper: is a directory writable ?
#
dir_writable () {
	if [ -d "$1/" ] && [ -w "$1/" ] && touch -a "$1/" 2>/dev/null
	then
		return 0
	fi
	return 1
}

#
#	Set SULOGIN in /etc/default/rcS to yes if you want a sulogin to
#	be spawned from this script *before anything else* with a timeout,
#	like sysv does.
#
[ "$SULOGIN" = yes ] && sulogin -t 30 $CONSOLE

KERNEL=`uname -s`
RELEASE=`uname -r`
MACHINE=`uname -m`

#
#	Ensure that bdflush (update) is running before any major I/O is
#	performed (the following fsck is a good example of such activity :).
#	Only needed for kernels < 2.4.
#
if [ -x /sbin/update ] && [ "$KERNEL" = Linux ]
then
	case "$RELEASE" in
		0.*|1.*|2.[0123].*)
			update
		;;
	esac
fi

#
#	Read /etc/fstab.
#
exec 9>&0 </etc/fstab
fstabroot=/dev/root
rootdev=none
roottype=none
rootopts=defaults
rootmode=rw
rootcheck=no
swap_on_md=no
devfs=
while read dev mnt type opts dump pass junk
do
	case "$dev" in
		""|\#*)
			continue;
			;;
		/dev/md*)
			# Swap on md device.
			[ "$type" = swap ] && swap_on_md=yes
			;;
		/dev/*)
			;;
 		LABEL=*|UUID=*)
 			[ -x /sbin/findfs ] && dev="`/sbin/findfs \"$dev\"`"
			;;
		*)
			# Devfs definition ?
			if [ "$type" = "devfs" ] && [ "$mnt" = /dev ] &&
			   mountpoint -q /dev
			then
				devfs="-t $type $dev $mnt"
			fi

			# Might be a swapfile.
			[ "$type" = swap ] && swap_on_md=yes
			;;
	esac
	[ "$mnt" != / ] && continue
	rootdev="$dev"
	fstabroot="$dev"
	rootopts="$opts"
	roottype="$type"
	( [ "$pass" != 0 ] && [ "$pass" != "" ]   ) && rootcheck=yes
	( [ "$type" = nfs ] || [ "$type" = nfs4 ] ) && rootcheck=no
	case "$opts" in
		ro|ro,*|*,ro|*,ro,*)
			rootmode=ro
			;;
	esac
done
exec 0>&9 9>&-

#
#	Activate the swap device(s) in /etc/fstab. This needs to be done
#	before fsck, since fsck can be quite memory-hungry.
#
doswap=no
case "${KERNEL}:${RELEASE}" in
	Linux:2.[0123].*)
		if [ $swap_on_md = yes ] && grep -qs resync /proc/mdstat
		then
			[ "$VERBOSE" != no ] &&
			  echo "Not activating swap - RAID array resyncing"
		else
			doswap=yes
		fi
		;;
	*)
		doswap=yes
		;;
esac
if [ "$doswap" = yes ]
then
	[ "$VERBOSE" != no ] && echo "Activating swap."
	swapon -a 2> /dev/null
fi

#
#	Does the root device in /etc/fstab match with the actual device ?
#	If not we try to use the /dev/root alias device, and if that
#	fails we create a temporary node in /dev/shm.
#
if [ "$rootcheck" = yes ]
then
	ddev=`mountpoint -qx $rootdev`
	rdev=`mountpoint -d /`
	if [ "$ddev" != "$rdev" ] && [ "$ddev" != "4:0" ]
	then
		if [ "`mountpoint -qx /dev/root`" = "4:0" ]
		then
			rootdev=/dev/root
		elif dir_writable /dev/shm
		then
			rm -f /dev/shm/root
			mknod -m 600 /dev/shm/root b ${rdev%:*} ${rdev#*:}
			rootdev=/dev/shm/root
		else
			rootfatal=yes
		fi
	fi
fi

#
#	Bother, said Pooh.
#
if [ "$rootfatal" = yes ]
then
	echo
	echo "The device node $rootdev for the root filesystem is missing,"
	echo "incorrect, or there is no entry for the root filesystem"
	echo "listed in /etc/fstab."
	echo
	echo "The system is also unable to create a temporary node in"
	echo "/dev/shm to use as a work-around."
	echo
	echo "This means you have to fix this manually."
	echo
	echo "CONTROL-D will exit from this shell and REBOOT the system."
	echo
	# Start a single user shell on the console
	/sbin/sulogin $CONSOLE
	reboot -f
fi

#
#	See if we want to check the root file system.
#
FSCKCODE=0
if [ -f /fastboot ] || [ $rootcheck = no ]
then
	[ $rootcheck = yes ] && echo "Fast boot, no file system check"
	rootcheck=no
fi

if [ "$rootcheck" = yes ]
then
	#
	# Ensure that root is quiescent and read-only before fsck'ing.
	#
	# mount -n -o remount,ro / would be the correct syntax but
	# mount can get confused when there is a "bind" mount defined
	# in fstab that bind-mounts "/" somewhere else.
	#
	# So we use mount -n -o remount,ro $rootdev / but that can
	# fail on older kernels on sparc64/alpha architectures due
	# to a bug in sys_mount().
	#
	# As a compromise we try both.
	#
	if ! mount -n -o remount,ro $rootdev / 2>/dev/null &&
	   ! mount -n -o remount,ro /
	then
    		echo -n "*** ERROR!  Cannot fsck root fs because it is "
		echo    "not mounted read-only!"
		echo
		rootcheck=no
	fi
fi

#
#	The actual checking is done here.
#
if [ "$rootcheck" = yes ]
then
	if [ -f /forcefsck ]
	then
		force="-f"
	else
		force=""
	fi

	if [ "$FSCKFIX" = yes ]
	then
		fix="-y"
	else
		fix="-a"
	fi

	spinner="-C"
	case "$TERM" in
		dumb|network|unknown|"")
			spinner="" ;;
	esac
	# This Linux/s390 special case should go away.
	if [ "${KERNEL}:${MACHINE}" = Linux:s390 ]
	then
		spinner=""
	fi

	echo "Checking root file system..."
	fsck $spinner $force $fix -t $roottype $rootdev
	FSCKCODE=$?
fi

#
#	If there was a failure, drop into single-user mode.
#
#	NOTE: "failure" is defined as exiting with a return code of
#	4 or larger.  A return code of 1 indicates that file system
#	errors were corrected but that the boot may proceed. A return
#	code of 2 or 3 indicates that the system should immediately reboot.
#
if [ $FSCKCODE -gt 3 ]
then
	# Surprise! Re-directing from a HERE document (as in
	# "cat << EOF") won't work, because the root is read-only.
	echo
	echo "fsck failed.  Please repair manually and reboot.  Please note"
	echo "that the root file system is currently mounted read-only.  To"
	echo "remount it read-write:"
	echo
	echo "   # mount -n -o remount,rw /"
	echo
	echo "CONTROL-D will exit from this shell and REBOOT the system."
	echo
	# Start a single user shell on the console
	/sbin/sulogin $CONSOLE
	reboot -f
elif [ $FSCKCODE -gt 1 ]
then
	echo
	echo "fsck corrected errors on the root partition, but requested that"
	echo "the system be rebooted (exit code $FSCKCODE)."
	echo
	echo "Automatic reboot in 5 seconds."
	echo
	sleep 5
	reboot -f
fi

#
#	Remount root to final mode (rw or ro).
#
#	See the comments above at the previous "mount -o remount"
#	for an explanation why we try this twice.
#
#if ! mount -n -o remount,$rootopts,$rootmode $fstabroot / 2>/dev/null \
#  && ! grep -q "mini_fo" /proc/mounts \
#    && ! grep -q "/dev/sd[a-d][1-9] / ext[2|3]" /proc/mounts
#then
#	mount -n -o remount,$rootopts,$rootmode /
#fi

#
#	We only create/modify /etc/mtab if the location where it is
#	stored is writable.  If /etc/mtab is a symlink into /proc/
#	then it is not writable.
#
init_mtab=no
MTAB_PATH="`readlink -f /etc/mtab || :`"
case "$MTAB_PATH" in
	/proc/*)
		;;
	/*)
		if dir_writable ${MTAB_PATH%/*}
		then
			:> $MTAB_PATH
			rm -f ${MTAB_PATH}~
			init_mtab=yes
		fi
		;;
	"")
		[ -L /etc/mtab ] && MTAB_PATH="`readlink /etc/mtab`"
		if [ "$MTAB_PATH" ] ; then
			echo "checkroot.sh: cannot initialize $MTAB_PATH" >&2
		else
			echo "checkroot.sh: cannot initialize the mtab file" >&2
		fi
		;;
esac

if [ "$init_mtab"  = yes ]
then
	[ "$roottype" != none ] &&
		mount -f -o $rootopts -t $roottype $fstabroot /
	[ -n "$devfs" ] && mount -f $devfs
	. /etc/init.d/mountvirtfs
fi

#
#	Remove /etc/nologin, and /dev/shm/root if we created it.
#
NOLOGIN="`readlink -f /etc/nologin || :`"
rm -f "$NOLOGIN"
rm -f /dev/shm/root

: exit 0

