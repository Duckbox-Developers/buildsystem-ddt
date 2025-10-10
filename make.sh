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
	echo "Parameter 1                             : Target system (1-91)"
	echo "Parameter 2 (ARM/MIPS, not DM800)       : GCC Version (1-12)"
	echo "Parameter 3 (not UFS910/UFS922/DM800)   : FFMPEG Version (1-5)"
	echo "Parameter 4                             : Optimization (1-6)"
	echo "Parameter 5                             : External LCD support (1-4)"
	echo "Parameter 6                             : Neutrino variant (1-4)"
	echo "Parameter 7 (HD51/H7/BRE2ZE4K/E4HDULTRA): Swap Data and Linux Swap (1-3, 81-83)"
	echo "Parameter 8 (HD51/H7/BRE2ZE4K/E4HDULTRA): Kernel size in MB (default: 8)"
	echo "Parameter 9 (HD51/H7/BRE2ZE4K/E4HDULTRA): Swap size in MB (default: 128)"
	echo "Parameter 10 (ARM VU+)                  : Normal/Multiboot (1-2)"
	exit
fi

##############################################

if [ "$1" != "" ]; then
	# defaults
	echo "BOXTYPE=$1" > config
	echo "OPTIMIZATIONS=size" >> config
	echo "OPTIMIZE_PICS=1" >> config
	echo "EXTERNAL_LCD=none" >> config
	echo "FLAVOUR=neutrino-ddt" >> config
	echo "IMAGE=neutrino" >> config
	echo "SWAPDATA=0" >> config
	echo "VU_MULTIBOOT=1" >> config
	case $1 in
		ufs910|ufs912|ufs913|ufs922|tf7700|fortis_hdbox|octagon1008|atevio7500|ipbox55|ipbox99|ipbox9900|cuberevo|cuberevo_mini|cuberevo_mini2|cuberevo_250hd|cuberevo_2000hd|cuberevo_3000hd|spark|spark7162)
			echo "BOXARCH=sh4" >> config
			echo "BS_GCC_VER=4.8.4" >> config
			[ "$1" == "ufs910" -o "$1" == "ufs922" ] && echo "FFMPEG_VER=2.8" >> config || echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
		dcube)
			echo "BOXARCH=arm" >> config
			echo "BS_GCC_VER=4.9.4" >> config
			echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
		hd51|h7|bre2ze4k|e4hdultra|vusolo4k|vuuno4k|vuultimo4k|vuzero4k|vuuno4kse|vuuno4k|vuduo4kse|dm900|dm920)
			echo "BOXARCH=arm" >> config
			echo "BS_GCC_VER=8.5.0" >> config
			echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
		dm800)
			echo "BOXARCH=mips" >> config
			echo "BS_GCC_VER=4.9.4" >> config
			echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
		vuduo|vuduo2|vuuno|vuultimo|dm800se|dm800sev2|dm8000|dm7020hd|dm820|dm7080)
			echo "BOXARCH=mips" >> config
			echo "BS_GCC_VER=8.5.0" >> config
			echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
	esac
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 5[0-9] | 6[0-9] | 7[0-9] | 8[0-9] | 9[0-9]) REPLY=$1;;
	*)
		clear
		echo "Target receivers:"
		echo
		echo "  sh4-based receivers"
		echo "  Kathrein               Fortis"
		echo "    1) UFS-910            6) FS9000 / FS9200 (formerly Fortis HDBox / Atevio AV7000)"
		echo "    2) UFS-912            7) HS9510          (formerly Octagon SF1008P / Atevio AV700)"
		echo "    3) UFS-913            8) HS8200          (formerly Atevio AV7500)"
		echo "    4) UFS-922"
		echo
		echo "  Topfield"
		echo "    5) TF77X0 HDPVR"
		echo
		echo "  AB IPBox              Cuberevo"
		echo "    9) 55HD              12) id."
		echo "   10) 99HD              13) mini"
		echo "   11) 9900HD            14) mini2"
		echo "   12) 9000HD            15) 250HD"
		echo "   13) 900HD             16) 2000HD"
		echo "   14) 910HD             17) 3000HD / Xsarius Alpha"
		echo "   15) 91HD"
		echo
		echo "  Fulan"
		echo "   27) Spark             28) Spark7162"
		echo
		echo "  VU+ mips-based receivers"
		echo "   31) VU+ Duo           32) VU+ Duo2           33) VU+ Uno            34) VU+ Ultimo"
		echo
		echo "  VU+ arm-based receivers"
		echo "   41) VU+ Solo 4K       42) VU+ Uno 4K         43) VU+ Ultimo 4K      44) VU+ Zero 4K"
		echo "   45) VU+ Uno 4K SE     46) VU+ Duo 4K         47) VU+ Duo 4K SE"
		echo
		echo "  other arm-based receivers"
		echo "  AX/Mut@nt             Air Digital            WWIO"
		echo -e "   \033[01;32m51) HD51\033[00m              57) ZGEMMA H7          58) WWIO BRE2ZE 4K"
		echo
		echo "  AXAS"
		echo "   66) AXAS E4HD 4K Ultra"
		echo
		echo "  other old arm-based receivers"
		echo "   71) D-Cube R2"
		echo
		echo "  Dreambox mips-based receivers"
		echo "   80) DM 800 HD         81) DM800 HD SE        82) DM800 HD SE v2     83) DM8000 HD"
		echo "   84) DM 7020 HD        85) DM 820 HD          86) DM 7080 HD"
		echo
		echo "  Dreambox arm-based receivers"
		echo "   90) DM 900 UHD        91) DM 920 UHD"
		echo
		read -p "Select target (1-91)? ";;
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

	31) BOXARCH="mips";BOXTYPE="vuduo";;
	32) BOXARCH="mips";BOXTYPE="vuduo2";;
	33) BOXARCH="mips";BOXTYPE="vuuno";;
	34) BOXARCH="mips";BOXTYPE="vuultimo";;

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

	71) BOXARCH="arm";BOXTYPE="dcube";;

	80) BOXARCH="mips";BOXTYPE="dm800";;
	81) BOXARCH="mips";BOXTYPE="dm800se";;
	82) BOXARCH="mips";BOXTYPE="dm800sev2";;
	83) BOXARCH="mips";BOXTYPE="dm8000";;
	84) BOXARCH="mips";BOXTYPE="dm7020hd";;
	85) BOXARCH="mips";BOXTYPE="dm820";;
	86) BOXARCH="mips";BOXTYPE="dm7080";;

	90) BOXARCH="arm";BOXTYPE="dm900";;
	91) BOXARCH="arm";BOXTYPE="dm920";;

	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

if [ $BOXARCH == "sh4" ]; then
	CURDIR=`pwd`
	echo -ne "\n   Checking the .elf files in $CURDIR/root/boot..."
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

if [ $BOXTYPE == 'dm800' ]; then
	echo "BS_GCC_VER=4.9.4" >> config
elif [ $BOXARCH == 'arm' -o $BOXARCH == 'mips' ]; then
	case $2 in
		[1-9] | 1[0-2]) REPLY=$2;;
		*)	echo -e "\nSelect GCC version:"
			if [ $BOXTYPE == 'dcube' ]; then
				echo -e "   \033[01;32m1)  GCC version 4.9.4\033[00m"
				echo "   2)  GCC version 5.5.0"
				echo "   3)  GCC version 6.5.0"
				read -p "Select GCC version (1-3)? "
			else
				echo "   3)  GCC version 6.5.0"
				echo "   4)  GCC version 7.5.0"
				echo -e "   \033[01;32m5)  GCC version 8.5.0\033[00m"
				echo "   6)  GCC version 9.5.0"
				echo "   7)  GCC version 10.5.0"
				echo "   8)  GCC version 11.5.0"
				echo "   9)  GCC version 12.5.0"
				echo "  10)  GCC version 13.4.0"
				echo "  11)  GCC version 14.3.0"
				echo "  12)  GCC version 15.2.0"
				read -p "Select GCC version (3-12)? "
			fi;;
	esac

	case "$REPLY" in
		 1) BS_GCC_VER="4.9.4";;
		 2) BS_GCC_VER="5.5.0";;
		 3) BS_GCC_VER="6.5.0";;
		 4) BS_GCC_VER="7.5.0";;
		 5) BS_GCC_VER="8.5.0";;
		 6) BS_GCC_VER="9.5.0";;
		 7) BS_GCC_VER="10.5.0";;
		 8) BS_GCC_VER="11.5.0";;
		 9) BS_GCC_VER="12.5.0";;
		10) BS_GCC_VER="13.4.0";;
		11) BS_GCC_VER="14.3.0";;
		12) BS_GCC_VER="15.2.0";;
		 *) [ $BOXTYPE == 'dcube' -o $BOXTYPE == 'dm800' ] && BS_GCC_VER="4.9.4" || BS_GCC_VER="8.5.0";;
	esac
	echo "BS_GCC_VER=$BS_GCC_VER" >> config
else
	echo "BS_GCC_VER=4.8.4" >> config
fi

##############################################

if [ "$BOXARCH" == "sh4" ]; then
	LOCAL_FFMPEG_BOXTYPE_LIST='octagon1008 fortis_hdbox cuberevo cuberevo_3000hd cuberevo_mini cuberevo_mini2 ufs912 ufs913 spark atevio7500'
	for i in $LOCAL_FFMPEG_BOXTYPE_LIST; do
		if [ "$BOXTYPE" == "$i" ]; then
			LOCAL_FFMPEG_BOXTYPE_LIST=$BOXTYPE
			echo "LOCAL_FFMPEG_BOXTYPE_LIST=$LOCAL_FFMPEG_BOXTYPE_LIST" >> config
			case $3 in
				[1-3]) REPLY=$3;;
				*)	echo -e "\nFFMPEG version:"
					echo "   1)  FFMPEG 3.4 GIT\033[00m"
					echo -e "   \033[01;32m2)  FFMPEG 4.4 GIT\033[00m"
					echo "   3)  FFMPEG 5.1 GIT [experimental]"
					read -p "Select FFMPEG version (1-3)? "
					;;
			esac

			case "$REPLY" in
				1)  FFMPEG_VER="3.4";;
				2)  FFMPEG_VER="4.4";;
				3)  FFMPEG_VER="5.1";;
				*)  FFMPEG_VER="4.4";;
			esac
			echo "FFMPEG_VER=$FFMPEG_VER" >> config
		fi
	done
	[ -z "$FFMPEG_VER" ] && echo "FFMPEG_VER=2.8" >> config
elif [ $BOXTYPE == 'dm800' ]; then
	echo "FFMPEG_VER=4.4" >> config
elif [ "$BOXARCH" == "arm" -o "$BOXARCH" == "mips" ]; then
	CNT=0
	case $3 in
		[1-5]) REPLY=$3;;
		*)	echo -e "\nFFMPEG version:"
			echo -e "   \033[01;32m1)  FFMPEG 4.4    GIT\033[00m" && CNT=$(($CNT+1))
			echo "   2)  FFMPEG 6.1    GIT [experimental]" && CNT=$(($CNT+1))
			if [ "$BOXTYPE" != "dcube" -a "$BOXTYPE" != "dm800" ]; then
				echo "   3)  FFMPEG 7.1    GIT [experimental]" && CNT=$(($CNT+1))
				echo "   4)  FFMPEG 8.0    GIT [experimental]" && CNT=$(($CNT+1))
				echo "   5)  FFMPEG MASTER GIT [experimental]" && CNT=$(($CNT+1))
			fi
			read -p "Select FFMPEG version (1-$CNT)? "
			;;
	esac

	case "$REPLY" in
		1)  FFMPEG_VER="4.4";;
		2)  FFMPEG_VER="6.1";;
		3)  FFMPEG_VER="7.1";;
		4)  FFMPEG_VER="8.0";;
		5)  FFMPEG_VER="master";;
		*)  FFMPEG_VER="4.4";;
	esac
	echo "FFMPEG_VER=$FFMPEG_VER" >> config
fi

##############################################

case $4 in
	[1-6]) REPLY=$4;;
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

case $5 in
	[1-4]) REPLY=$5;;
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

case $6 in
	[1-4]) REPLY=$6;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo -e "   \033[01;32m1)  neutrino-ddt\033[00m"
		echo "   2)  neutrino-ddt (includes WLAN drivers)"
		if [ "$BOXARCH" != "sh4" -a "$BOXTYPE" != "vuuno" -a "$BOXTYPE" != "vuultimo" -a "$BOXTYPE" != "dm800" -a "$BOXTYPE" != "dm800se" -a "$BOXTYPE" != "dm800sev2" -a "$BOXTYPE" != "dm8000" -a "$BOXTYPE" != "dm7020hd" -a "$BOXTYPE" != "dm820" -a "$BOXTYPE" != "dm7080" -a "$BOXTYPE" != "dm900" -a "$BOXTYPE" != "dm920" -a "$BOXTYPE" != "dcube" ]; then
			echo "   3)  neutrino-tangos"
			echo "   4)  neutrino-tangos (includes WLAN drivers)"
		fi
		read -p "Select Image to build (1-4)? ";;
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
	*)  FLAVOUR="neutrino-ddt"
	    IMAGE="neutrino";;
esac
echo "FLAVOUR=$FLAVOUR" >> config
echo "IMAGE=$IMAGE" >> config

##############################################

# dataswap linuxswap hd51/h7/bre2ze4k/e4hdultra

if [ $BOXTYPE == 'hd51' -o $BOXTYPE == 'h7' -o $BOXTYPE == 'bre2ze4k' -o $BOXTYPE == 'e4hdultra' ]; then
	case $7 in
		[1-3] | 8[1-3]) REPLY=$7;;
		*)	echo -e "\nSwap Data and Linux Swap:"
			echo -e "   \033[01;32m 1)  Swap OFF\033[00m"
			echo -e "    2)  Swap ON (1x linux swap, 1x ext4 swap)"
			echo -e "    3)  Swap ON (1x linux swap)"
			if [ $BOXTYPE == 'e4hdultra' ]; then
				echo ""
				echo    "   AXAS E4HD 4K Ultra - 8 GB FLASH version:"
				echo -e "   81)  Swap OFF\033[00m"
				echo -e "   82)  Swap ON (1x linux swap, 1x ext4 swap)"
				echo -e "   83)  Swap ON (1x linux swap)"
				read -p "Select SWAP support (1-3, 81-83)? "
			else
				read -p "Select SWAP support (1-3)? "
			fi;;
	esac

	case "$REPLY" in
		1)  SWAPDATA="0"
		    SWPCNT=0;;
		2)  SWAPDATA="1"
		    SWPCNT=2;;
		3)  SWAPDATA="2"
		    SWPCNT=1;;
		81) SWAPDATA="80"
		    SWPCNT=0;;
		82) SWAPDATA="81"
		    SWPCNT=2;;
		83) SWAPDATA="82"
		    SWPCNT=1;;
		*)  SWAPDATA="0"
		    SWPCNT=0;;
	esac
	echo "SWAPDATA=$SWAPDATA" >> config

	[ $SWAPDATA -gt 79 -a $SWAPDATA -lt 83 ] && EMMC_IMAGE_SIZE=7634944 || EMMC_IMAGE_SIZE=3817472
	echo "EMMC_IMAGE_SIZE=$EMMC_IMAGE_SIZE" >> config

	case $8 in
		[6-9]|1[0-9]) REPLY=$8;;
		*)	echo ""
			read -p $'Kernelsize in MB, 6..19 \033[01;32m(default: 8)\033[00m? ' REPLY;;
	esac
	[ ! -z $REPLY ] && KERNEL_PARTITION_SIZE=$(($REPLY*1024)) || KERNEL_PARTITION_SIZE=8192
	echo "KERNEL_PARTITION_SIZE=$KERNEL_PARTITION_SIZE" >> config

	if [ $SWPCNT -gt 0 ]; then
		case $9 in
			[1-9][0-9]|[1-9][0-9][0-9]|10[0-2][0-4]) REPLY=$9;;
			*)	echo ""
				read -p $'Swapsize in MB, 10..1024 \033[01;32m(default: 128)\033[00m? ' REPLY;;
		esac
		[ ! -z $REPLY ] && SWAP_DATA_PARTITION_SIZE=$(($REPLY*1024)) || SWAP_DATA_PARTITION_SIZE=131072
		echo "SWAP_DATA_PARTITION_SIZE=$SWAP_DATA_PARTITION_SIZE" >> config
	else
		SWAP_DATA_PARTITION_SIZE=0
		echo "SWAP_DATA_PARTITION_SIZE=$SWAP_DATA_PARTITION_SIZE" >> config
	fi

	BOOT_PARTITION_SIZE=1024
	ROOTFS_PARTITION_SIZE_MULTI=`expr $EMMC_IMAGE_SIZE \- $BOOT_PARTITION_SIZE \- $SWAP_DATA_PARTITION_SIZE \* $SWPCNT \- $KERNEL_PARTITION_SIZE \* 4`
	ROOTFS_PARTITION_SIZE_MULTI=`expr $ROOTFS_PARTITION_SIZE_MULTI \/ 4 \- 768`
	echo "ROOTFS_PARTITION_SIZE_MULTI=$ROOTFS_PARTITION_SIZE_MULTI" >> config

	echo ""
	echo "---------------------------------------------------------"
	echo "Using flashsize                 : $EMMC_IMAGE_SIZE	($(($EMMC_IMAGE_SIZE/1024)) MB)"
	echo "---------------------------------------------------------"
	echo "BOOT_PARTITION_SIZE         (1x): $BOOT_PARTITION_SIZE		($(($BOOT_PARTITION_SIZE/1024)) MB)"
	echo "KERNEL_PARTITION_SIZE       (4x): $KERNEL_PARTITION_SIZE		($(($KERNEL_PARTITION_SIZE/1024)) MB)"
	[ $SWPCNT -gt 0 ] && echo "SWAP_DATA_PARTITION_SIZE    (${SWPCNT}x): $SWAP_DATA_PARTITION_SIZE	($(($SWAP_DATA_PARTITION_SIZE/1024)) MB)"
	echo "ROOTFS_PARTITION_SIZE_MULTI (4x): $ROOTFS_PARTITION_SIZE_MULTI	($(($ROOTFS_PARTITION_SIZE_MULTI/1024)) MB)"
	echo "---------------------------------------------------------"
fi

##############################################

# Multiboot for VUPLUS_ARM
if [ $BOXTYPE == 'vusolo4k' -o $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuduo4kse' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' -o $BOXTYPE == 'vuzero4k' ]; then
	case ${10} in
		[1-2]) REPLY=${10};;
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
