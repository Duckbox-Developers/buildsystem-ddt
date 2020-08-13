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

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1           : Target system (1-70)"
	echo "Parameter 2 (SH4)     : Kernel (1-2)"
	echo "Parameter 2 (ARM VU+) : Single/Multiboot (1-2)"
	echo "Parameter 2 (MIPS/ARM): unused, use \"-\" as placeholder for batch mode"
	echo "Parameter 3           : Optimization (1-4)"
	echo "Parameter 4           : Image Neutrino (1-2)"
	echo "Parameter 5           : Neutrino variant (1-4)"
	echo "Parameter 6           : External LCD support (1-4)"
	echo "Parameter 7 (ARM/MIPS): GCC Version (1-4)"
	echo "Parameter 8 (ARM VU+) : old/actual kernel modules (1-2)"
	exit
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 5[0-9] | 6[0-9] | 7[0-9]) REPLY=$1;;
	*)
		clear
		echo "Target receivers:"
		echo
		echo "  sh4-based receivers"
		echo "  Kathrein             Fortis"
		echo "    1)  UFS-910          6)  FS9000 / FS9200 (formerly Fortis HDBox / Atevio AV7000)"
		echo "    2)  UFS-912          7)  HS9510          (formerly Octagon SF1008P / Atevio AV700)"
		echo "    3)  UFS-913          8)  HS8200          (formerly Atevio AV7500)"
		echo "    4)  UFS-922"
		echo
		echo "  Topfield"
		echo "    5)  TF77X0 HDPVR"
		echo
		echo "  AB IPBox             Cuberevo"
		echo "    9)  55HD            12)  id."
		echo "   10)  99HD            13)  mini"
		echo "   11)  9900HD          14)  mini2"
		echo "   12)  9000HD          15)  250HD"
		echo "   13)  900HD           16)  2000HD"
		echo "   14)  910HD           17)  3000HD / Xsarius Alpha"
		echo "   15)  91HD"
		echo
		echo "  Fulan"
		echo "   27)  Spark"
		echo "   28)  Spark7162"
		echo
		echo "  arm-based receivers"
		echo "  AX/Mut@nt            VU+"
		echo "   51)  HD51            50) VU+ Solo 4K     54) VU+ Ultimo 4K"
		echo "                        52) VU+ Duo 4K      55) VU+ Uno 4K SE"
		echo "                        53) VU+ Zero 4K     56) VU+ Uno 4K"
		echo "  Air Digital"
		echo "   57)  ZGEMMA H7"
		echo
		echo "  WWIO"
		echo "   58) WWIO BRE2ZE 4K"
		echo
		echo "  mips-based receivers"
		echo "   70)  VU+ Duo"
		echo
		read -p "Select target (1-70)? ";;
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

	50) BOXARCH="arm";BOXTYPE="vusolo4k";;
	51) BOXARCH="arm";BOXTYPE="hd51";;
	52) BOXARCH="arm";BOXTYPE="vuduo4k";;
	53) BOXARCH="arm";BOXTYPE="vuzero4k";;
	54) BOXARCH="arm";BOXTYPE="vuultimo4k";;
	55) BOXARCH="arm";BOXTYPE="vuuno4kse";;
	56) BOXARCH="arm";BOXTYPE="vuuno4k";;
	57) BOXARCH="arm";BOXTYPE="h7";;
	58) BOXARCH="arm";BOXTYPE="bre2ze4k";;

	70) BOXARCH="mips";BOXTYPE="vuduo";;
	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

# Multiboot for VUPLUS_ARM
if [ $BOXTYPE == 'vusolo4k' -o $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' -o $BOXTYPE == 'vuzero4k' ]; then
	case $2 in
		[1-2]) REPLY=$2;;
		*)	echo -e "\nNormal or MultiBoot:"
			echo "   1)  Normal    (default)"
			echo "   2)  Multiboot"
			read -p "Select mode (1-2)? ";;
	esac

	case "$REPLY" in
		1)  VU_MULTIBOOT="0";;
		2)  VU_MULTIBOOT="1";;
		*)  VU_MULTIBOOT="0";;
	esac
	echo "VU_MULTIBOOT=$VU_MULTIBOOT" >> config
fi

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

	case $2 in
		[1-2]) REPLY=$2;;
		*)	echo -e "\nKernel:"
			echo "   1)  STM 24 P0209 [2.6.32.46]"
			echo "   2)  STM 24 P0217 [2.6.32.71] (default) use this"
			read -p "Select kernel (1-2)? ";;
	esac

	case "$REPLY" in
		1)  KERNEL_STM="p0209";;
		2)  KERNEL_STM="p0217";;
		*)  KERNEL_STM="p0217";;
	esac
	echo "KERNEL_STM=$KERNEL_STM" >> config
fi

##############################################

case $3 in
	[1-4]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1)  optimization for size"
		echo "   2)  optimization normal (current only SH4 or ARM/MIPS with GCC 6)"
		echo "   3)  Kernel debug"
		echo "   4)  debug (includes Kernel debug)"
		read -p "Select optimization (1-4)? ";;
esac

case "$REPLY" in
	1)  OPTIMIZATIONS="size";;
	2)  OPTIMIZATIONS="normal";;
	3)  OPTIMIZATIONS="kerneldebug";;
	4)  OPTIMIZATIONS="debug";;
	*)  OPTIMIZATIONS="size";;
esac
echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config

##############################################

case $4 in
	[1-2]) REPLY=$4;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Neutrino"
		echo "   2)  Neutrino (includes WLAN drivers)"
		read -p "Select Image to build (1-2)? ";;
esac

case "$REPLY" in
	1) IMAGE="neutrino";;
	2) IMAGE="neutrino-wlandriver";;
	*) IMAGE="neutrino";;
esac
echo "IMAGE=$IMAGE" >> config

##############################################

case $5 in
	[1-3]) REPLY=$5;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo "   1)  neutrino-ddt               [ arm/sh4 ]"
		echo "   2)  neutrino-tangos            [ arm/sh4 ]"
		echo "   3)  neutrino-ddt with youtube  [ arm/sh4 ]"
		read -p "Select Image to build (1-3)? ";;
esac

case "$REPLY" in
	1) FLAVOUR="neutrino-ddt";;
	2) FLAVOUR="neutrino-tangos";;
	3) FLAVOUR="neutrino-ddt-youtube";;
	*) FLAVOUR="neutrino-ddt";;
esac
echo "FLAVOUR=$FLAVOUR" >> config

##############################################

case $6 in
	[1-4]) REPLY=$6;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1)  No external LCD"
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

# gcc version for ARM/MIPS
if [ $BOXARCH == 'arm' -o $BOXARCH == 'mips' ]; then
	case $7 in
		[1-4]) REPLY=$7;;
		*)	echo -e "\nSelect GCC version:"
			echo "   1)  GCC version 6.5.0 (default)"
			echo "   2)  GCC version 7.5.0"
			echo "   3)  GCC version 8.3.0"
			echo "   4)  GCC version 9.2.0"
			read -p "Select modul version (1-4)? [1] "
			REPLY="${REPLY:-1}";;
	esac

	case "$REPLY" in
		1)  BS_GCC_VER="6.5.0";;
		2)  BS_GCC_VER="7.5.0";;
		3)  BS_GCC_VER="8.3.0";;
		4)  BS_GCC_VER="9.2.0";;
		*)  BS_GCC_VER="6.5.0";;
	esac
	echo "BS_GCC_VER=$BS_GCC_VER" >> config
fi

##############################################

# old/actual kernel modules for VUPLUS_ARM
if [ $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' ]; then
	case $8 in
		[1-2]) REPLY=$8;;
		*)	echo -e "\nOld or actual kernel modules:"
			echo "   1)  OLD kernel modules    (default)"
			echo "   2)  ACTUAL kernel modules"
			read -p "Select modul version (1-2)? ";;
	esac

	case "$REPLY" in
		1)  VU_NEW_MODULES="0";;
		2)  VU_NEW_MODULES="1";;
		*)  VU_NEW_MODULES="0";;
	esac
	echo "VU_NEW_MODULES=$VU_NEW_MODULES" >> config
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
