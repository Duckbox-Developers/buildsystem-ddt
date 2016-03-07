#
# bootclean.sh	Functions to clean /tmp, /var/run and /var/lock.
#
# Version:	@(#)bootclean.sh  2.86-2  27-Aug-2004  miquels@cistron.nl
#

cleantmp() {

	[ -f /tmp/.clean ] && return

	# Don't clean /tmp if TMPTIME < 0 or "infinite".
	case "$TMPTIME" in
		-*|infinite)
			return
			;;
	esac

	#
	#	Wipe /tmp, but exclude system files.
	#	Note that files _in_ lost+found _are_ deleted.
	#
	[ "$VERBOSE" != no ] && echo -n " /tmp"
	#
	#	If $TMPTIME is set to 0, we do not use any ctime expression
	#	at all, so we can also delete files with timestamps
	#	in the future!
	#
	if [ "$TMPTIME" = 0 ]
	then
		TEXPR=""
		DEXPR=""
	else
		TEXPR="-mtime +$TMPTIME -ctime +$TMPTIME -atime +$TMPTIME"
		DEXPR="-mtime +$TMPTIME -ctime +$TMPTIME"
	fi

	rm -f /tmp/.clean
	set -o noclobber
	:> /tmp/.clean
	set +o noclobber

	#
	#	Only clean out /tmp if it is world-writable. This ensures
	#	it really is a/the temp directory we're cleaning.
	#
	EXCEPT='! -name .
		! ( -path ./lost+found )
		! ( -path ./quota.user )
		! ( -path ./aquota.user )
		! ( -path ./quota.group )
		! ( -path ./aquota.group )
		! ( -path ./.journal )
		! ( -path ./.clean )
		! ( -path './...security*' )'

	( if cd /tmp && [ "`find . -perm -002 -maxdepth 0`" = "." ]
	  then
		# First remove all old files.
		find . -xdev $TEXPR $EXCEPT \
				! -type d -depth -print0 | xargs -0r rm -f
		# And then all empty directories.
		find . -xdev $DEXPR $EXCEPT \
				-type d -depth -exec rmdir \{\} \;
		rm -f .X*-lock
	  fi
	)
}

cleanlock() {
	#
	#	Clean up any stale locks.
	#

	[ -f /var/lock/.clean ] && return

	[ "$VERBOSE" != no ] && echo -n " /var/lock"
	( cd /var/lock && find . ! -type d -exec rm -f -- {} \; )
	rm -f /var/lock/.clean
	set -o noclobber
	:> /var/lock/.clean
	set +o noclobber
}

cleanrun() {
	#
	#	Clean up /var/run.
	#

	[ -f /var/run/.clean ] && return

	[ "$VERBOSE" != no ] && echo -n " /var/run"
	( cd /var/run && \
		find . ! -type d ! -name utmp ! -name innd.pid \
		-exec rm -f -- {} \; )
	rm -f /var/run/.clean
	set -o noclobber
	:> /var/run/.clean
	set +o noclobber
}

bootclean() {

	# Only run if find and xargs are available.
	if [ ! -x /bin/find ] && [ ! -x /usr/bin/find ]
	then
		return 0
	fi
	if [ ! -x /bin/xargs ] && [ ! -x /usr/bin/xargs ]
	then
		return 0
	fi

	if [ -f /tmp/.clean ] && [ -f /var/run/.clean ] &&
	   [ -f /var/lock/.clean ]
	then
		return
	fi

	[ "$VERBOSE" != no ] && echo -n "Cleaning"
	[ -d /tmp ] && cleantmp
	[ -d /var/run ] && cleanrun
	[ -d /var/lock ] && cleanlock
	[ "$VERBOSE" != no ] && echo "."
}

