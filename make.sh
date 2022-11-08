#!/bin/bash

##############################################

if [ "$(id -u)" = "0" ]; then
	echo ""
	echo "You are running as root. Do not do this, it is dangerous."
	echo "Aborting the build. Log in as a regular user and retry."
	echo ""
	exit 1
fi

##############################################
# check for link sh to bash instead of dash on Ubuntu (and possibly others)
/bin/sh --version 2>/dev/null | grep bash -s -q
if [ ! "$?" -eq "0" ]; then
	echo -e "\033[01;31m=========================================================="
	echo -e "===> ERROR - prepare-for-bs.sh not executet -> EXIT ! <==="
	echo -e "==========================================================\033[0m"
	exit
fi

##############################################

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1                             : Target system (1-80)"
	echo "Parameter 2 (not UFS910/UFS922)         : FFMPEG Version (1-3)"
	echo "Parameter 3                             : Optimization (1-6)"
	echo "Parameter 4                             : External LCD support (1-4)"
	echo "Parameter 5                             : Neutrino variant (1-6)"
	echo "Parameter 6 (HD51/H7/BRE2ZE4K/E4HDULTRA): Swap Data and Linux Swap (1-2)"
	echo "Parameter 7 (ARM/MIPS)                  : GCC Version (1-7)"
	echo "Parameter 8 (ARM VU+)                   : Normal/Multiboot (1-2)"
	exit
fi

##############################################

if [ "$1" != "" ]; then
	# defaults
	echo "FFMPEG_EXPERIMENTAL=1" > config
	echo "FFMPEG_SNAPSHOT=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "OPTIMIZE_PICS=1" >> config
	echo "EXTERNAL_LCD=none" >> config
	echo "FLAVOUR=neutrino-ddt" >> config
	echo "IMAGE=neutrino" >> config
	echo "SWAPDATA=0" >> config
	echo "BS_GCC_VER=8.5.0" >> config
	echo "VU_MULTIBOOT=1" >> config
	echo "BOXTYPE=$1" >> config
	case $1 in
		ufs910|ufs912|ufs913|ufs922|tf7700|fortis_hdbox|octagon1008|atevio7500|ipbox55|ipbox99|ipbox9900|cuberevo|cuberevo_mini|cuberevo_mini2|cuberevo_250hd|cuberevo_2000hd|cuberevo_3000hd|spark|spark7162)
			echo "BOXARCH=sh4" >> config
			make printenv
			exit
		;;
		hd51|h7|bre2ze4k|e4hdultra|vusolo4k|vuuno4k|vuultimo4k|vuzero4k|vuuno4kse|vuuno4k|vuduo4kse)
			echo "BOXARCH=arm" >> config
			make printenv
			exit
		;;
		vuduo|dm8000)
			echo "BOXARCH=mips" >> config
			make printenv
			exit
		;;
	esac
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 5[0-9] | 6[0-9] | 7[0-9] | 8[0-9]) REPLY=$1;;
	*)
		clear
		echo "Target receivers:"
		echo
		echo "  sh4-based receivers"
		echo "  Kathrein               Fortis"
		echo "    1)  UFS-910            6)  FS9000 / FS9200 (formerly Fortis HDBox / Atevio AV7000)"
		echo "    2)  UFS-912            7)  HS9510          (formerly Octagon SF1008P / Atevio AV700)"
		echo "    3)  UFS-913            8)  HS8200          (formerly Atevio AV7500)"
		echo "    4)  UFS-922"
		echo
		echo "  Topfield"
		echo "    5)  TF77X0 HDPVR"
		echo
		echo "  AB IPBox               Cuberevo"
		echo "    9)  55HD              12)  id."
		echo "   10)  99HD              13)  mini"
		echo "   11)  9900HD            14)  mini2"
		echo "   12)  9000HD            15)  250HD"
		echo "   13)  900HD             16)  2000HD"
		echo "   14)  910HD             17)  3000HD / Xsarius Alpha"
		echo "   15)  91HD"
		echo
		echo "  Fulan"
		echo "   27)  Spark"
		echo "   28)  Spark7162"
		echo
		echo "  arm-based receivers"
		echo "  VU+"
		echo "   41)  VU+ Solo 4K       42)  VU+ Uno 4K          43)  VU+ Ultimo 4K"
		echo "   44)  VU+ Zero 4K       45)  VU+ Uno 4K SE       46)  VU+ Duo 4K"
		echo "   47)  VU+ Duo 4K SE"
		echo
		echo "  AX/Mut@nt              Air Digital              WWIO"
		echo -e "   \033[01;32m51)  HD51\033[00m              57)  ZGEMMA H7           58)  WWIO BRE2ZE 4K"
		echo
		echo "  AXAS"
		echo "   66)  AXAS E4HD 4K Ultra"
		echo
		echo "  mips-based receivers"
		echo "   70)  VU+ Duo"
		echo "   80)  DM8000"
		echo
		read -p "Select target (1-80)? ";;
esac

case "$REPLY" in
	 1) BOXARCH="sh4";BOXTYPE="ufs910";;
	 2) BOXARCH="sh4";BOXTYPE="ufs912";;
	 3) BOXARCH="sh4";BOXTYPE="ufs913";;
	 4) BOXARCH="sh4";BOXTYPE="ufs922";;

	 5) BOXARCH="sh4";BOXTYPE="tf7700";;

	 6) BOXARCH="sh4";BOXTYPE="fortis_hdbox";;
	 7) BOXARCH="sh4";BOXTYPE="octagon1008";;
	 8) BOXARCH="sh4";BOXTYPE="atevio7500";;

	 9) BOXARCH="sh4";BOXTYPE="ipbox55";;
	10) BOXARCH="sh4";BOXTYPE="ipbox99";;
	11) BOXARCH="sh4";BOXTYPE="ipbox9900";;
	12) BOXARCH="sh4";BOXTYPE="cuberevo";;
	13) BOXARCH="sh4";BOXTYPE="cuberevo_mini";;
	14) BOXARCH="sh4";BOXTYPE="cuberevo_mini2";;
	15) BOXARCH="sh4";BOXTYPE="cuberevo_250hd";;
	16) BOXARCH="sh4";BOXTYPE="cuberevo_2000hd";;
	17) BOXARCH="sh4";BOXTYPE="cuberevo_3000hd";;

	27) BOXARCH="sh4";BOXTYPE="spark";;
	28) BOXARCH="sh4";BOXTYPE="spark7162";;

	41) BOXARCH="arm";BOXTYPE="vusolo4k";;
	42) BOXARCH="arm";BOXTYPE="vuuno4k";;
	43) BOXARCH="arm";BOXTYPE="vuultimo4k";;
	44) BOXARCH="arm";BOXTYPE="vuzero4k";;
	45) BOXARCH="arm";BOXTYPE="vuuno4kse";;
	46) BOXARCH="arm";BOXTYPE="vuduo4k";;
	47) BOXARCH="arm";BOXTYPE="vuduo4kse";;

	51) BOXARCH="arm";BOXTYPE="hd51";;
	57) BOXARCH="arm";BOXTYPE="h7";;
	58) BOXARCH="arm";BOXTYPE="bre2ze4k";;

	66) BOXARCH="arm";BOXTYPE="e4hdultra";;

	70) BOXARCH="mips";BOXTYPE="vuduo";;
	80) BOXARCH="mips";BOXTYPE="dm8000";;
	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

if [ $BOXARCH == "sh4" ]; then
	CURDIR=`pwd`
	echo -ne "\n    Checking the .elf files in $CURDIR/root/boot..."
	set='audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111'
	for i in $set;
	do
		if [ ! -e $CURDIR/root/boot/$i.elf ]; then
			echo -e "\n    ERROR: One or more .elf files are missing in ./root/boot!"
			echo "           ($i.elf is one of them)"
			echo
			echo "    Correct this and retry."
			echo
			exit
		fi
	done
	echo " [OK]"
	echo
	echo "KERNEL_STM=p0217" >> config
fi

##############################################

if [ "$BOXARCH" == "sh4" ]; then
	LOCAL_FFMPEG_BOXTYPE_LIST='octagon1008 fortis_hdbox cuberevo cuberevo_3000hd cuberevo_mini cuberevo_mini2 ufs912 ufs913 spark atevio7500'
	for i in $LOCAL_FFMPEG_BOXTYPE_LIST; do
		if [ "$BOXTYPE" == "$i" ]; then
			LOCAL_FFMPEG_BOXTYPE_LIST=$BOXTYPE
			echo "LOCAL_FFMPEG_BOXTYPE_LIST=$LOCAL_FFMPEG_BOXTYPE_LIST" >> config
		fi
	done
fi

if [ "$LOCAL_FFMPEG_BOXTYPE_LIST" == "$BOXTYPE" -o "$BOXARCH" == "arm" -o "$BOXARCH" == "mips" ]; then
	case $2 in
		[1-3]) REPLY=$2;;
		*)	echo -e "\nFFMPEG version:"
			echo -e "   \033[01;32m1)  FFMPEG 4.4\033[00m"
			echo "   2)  FFMPEG 4.4.2 [experimental]"
			echo "   3)  FFMPEG 5.1   [git snapshot]"
			read -p "Select optimization (1-3)? ";;
	esac

	case "$REPLY" in
		1)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="0";;
		2)  FFMPEG_EXPERIMENTAL="1"
		    FFMPEG_SNAPSHOT="0";;
		3)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="1";;
		*)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="0";;
	esac
	echo "FFMPEG_EXPERIMENTAL=$FFMPEG_EXPERIMENTAL" >> config
	echo "FFMPEG_SNAPSHOT=$FFMPEG_SNAPSHOT" >> config
fi

##############################################

case $3 in
	[1-6]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo -e "   \033[01;32m1)  optimization for size\033[00m"
		echo "   2)  optimization normal (current only SH4 or ARM/MIPS with GCC 6)"
		echo "   3)  optimization for size, incl. PNG/JPG"
		echo "   4)  optimization normal (current only SH4 or ARM/MIPS with GCC 6), incl. PNG/JPG"
		echo "   5)  Kernel debug"
		echo "   6)  debug (includes Kernel debug)"
		read -p "Select optimization (1-6)? ";;
esac

case "$REPLY" in
	1)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="0";;
	2)  OPTIMIZATIONS="normal"
	    OPTIMIZE_PICS="0";;
	3)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="1";;
	4)  OPTIMIZATIONS="normal"
	    OPTIMIZE_PICS="1";;
	5)  OPTIMIZATIONS="kerneldebug"
	    OPTIMIZE_PICS="0";;
	6)  OPTIMIZATIONS="debug"
	    OPTIMIZE_PICS="0";;
	*)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="0";;
esac
echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config
echo "OPTIMIZE_PICS=$OPTIMIZE_PICS" >> config

##############################################

case $4 in
	[1-4]) REPLY=$4;;
	*)	echo -e "\nExternal LCD support:"
		echo -e "   \033[01;32m1)  No external LCD\033[00m"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		echo "   4)  graphlcd and lcd4linux for external LCD (both)"
		read -p "Select external LCD support (1-4)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="none";;
	2) EXTERNAL_LCD="graphlcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	4) EXTERNAL_LCD="both";;
	*) EXTERNAL_LCD="none";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config

##############################################

case $5 in
	[1-6]) REPLY=$5;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo -e "   \033[01;32m1)  neutrino-ddt\033[00m"
		echo "   2)  neutrino-ddt (includes WLAN drivers)"
		if [ $BOXARCH != 'sh4' ]; then
			echo "   3)  neutrino-tangos"
			echo "   4)  neutrino-tangos (includes WLAN drivers)"
		fi
		echo "   5)  neutrino-ddt with youtube"
		echo "   6)  neutrino-ddt with youtube (includes WLAN drivers)"
		read -p "Select Image to build (1-6)? ";;
esac

case "$REPLY" in
	1)  FLAVOUR="neutrino-ddt"
	    IMAGE="neutrino";;
	2)  FLAVOUR="neutrino-ddt"
	    IMAGE="neutrino-wlandriver";;
	3)  FLAVOUR="neutrino-tangos"
	    IMAGE="neutrino";;
	4)  FLAVOUR="neutrino-tangos"
	    IMAGE="neutrino-wlandriver";;
	5)  FLAVOUR="neutrino-ddt-youtube"
	    IMAGE="neutrino";;
	6)  FLAVOUR="neutrino-ddt-youtube"
	    IMAGE="neutrino-wlandriver";;
	*)  FLAVOUR="neutrino-ddt"
	    IMAGE="neutrino";;
esac
echo "FLAVOUR=$FLAVOUR" >> config
echo "IMAGE=$IMAGE" >> config

##############################################

# dataswap linuxswap hd51/h7/bre2ze4k/e4hdultra

if [ $BOXTYPE == 'hd51' -o $BOXTYPE == 'h7' -o $BOXTYPE == 'bre2ze4k' -o $BOXTYPE == 'e4hdultra' ]; then
	case $6 in
		[1-2]) REPLY=$6;;
		*)	echo -e "\nSelect Swap Data and Linux Swap:"
			echo -e "   \033[01;32m1)  Swap OFF\033[00m"
			echo -e "   2)  Swap ON"
			read -p "Select SWAP support (1-2)? ";;
	esac

case "$REPLY" in
	1) SWAPDATA="0";;
	2) SWAPDATA="1";;
	*) SWAPDATA="0";;
esac
echo "SWAPDATA=$SWAPDATA" >> config
fi
##############################################

# gcc version for ARM/MIPS
if [ $BOXARCH == 'arm' -o $BOXARCH == 'mips' ]; then
	case $7 in
		[1-7]) REPLY=$7;;
		*)	echo -e "\nSelect GCC version:"
			echo "   1)  GCC version 6.5.0"
			echo "   2)  GCC version 7.5.0"
			echo -e "   \033[01;32m3)  GCC version 8.5.0\033[00m"
			echo "   4)  GCC version 9.5.0"
			echo "   5)  GCC version 10.4.0"
			echo "   6)  GCC version 11.3.0"
			echo "   7)  GCC version 12.2.0 (not yet ready)"
			read -p "Select GCC version (1-7)? ";;
	esac

	case "$REPLY" in
		1) BS_GCC_VER="6.5.0";;
		2) BS_GCC_VER="7.5.0";;
		3) BS_GCC_VER="8.5.0";;
		4) BS_GCC_VER="9.5.0";;
		5) BS_GCC_VER="10.4.0";;
		6) BS_GCC_VER="11.3.0";;
		7) BS_GCC_VER="12.2.0";;
		*) BS_GCC_VER="8.5.0";;
	esac
	echo "BS_GCC_VER=$BS_GCC_VER" >> config
else
	echo "BS_GCC_VER=4.8.4" >> config
fi

##############################################

# Multiboot for VUPLUS_ARM
if [ $BOXTYPE == 'vusolo4k' -o $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuduo4kse' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' -o $BOXTYPE == 'vuzero4k' ]; then
	case $8 in
		[1-2]) REPLY=$8;;
		*)	echo -e "\nNormal or MultiBoot:"
			echo -e "   \033[01;32m1)  Normal\033[00m"
			echo "   2)  Multiboot"
			read -p "Select boot mode (1-2)? ";;
	esac

	case "$REPLY" in
		1) VU_MULTIBOOT="0";;
		2) VU_MULTIBOOT="1";;
		*) VU_MULTIBOOT="0";;
	esac
	echo "VU_MULTIBOOT=$VU_MULTIBOOT" >> config
fi

##############################################

echo " "
make printenv
##############################################
echo "Your next step could be:"
case "$FLAVOUR" in
	neutrino*)
		echo "  make neutrino"
		echo "  make neutrino-plugins";;
	*)
		echo "  make flashimage"
		echo "  make ofgimage";;
esac
echo " "
