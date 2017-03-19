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
	echo "Parameter 1: target system (1-37)"
	echo "Parameter 2: kernel (1-2)"
	echo "Parameter 3: optimization (1-4)"
	echo "Parameter 4: player (1-2)"
	echo "Parameter 5: Media Framework (1-4)"
	echo "Parameter 6: External LCD support (1-3)"
	echo "Parameter 7: Image (Enigma=1/2 Neutrino=3/4 (1-4)"
	exit
fi

##############################################

echo "
  _______                     _____              _     _         _
 |__   __|                   |  __ \            | |   | |       | |
    | | ___  __ _ _ __ ___   | |  | |_   _  ____| | __| |_  __ _| | ___ ___
    | |/ _ \/ _\` | '_ \` _ \  | |  | | | | |/  __| |/ /| __|/ _\` | |/ _ | __|
    | |  __/ (_| | | | | | | | |__| | |_| |  (__|   < | |_| (_| | |  __|__ \\
    |_|\___|\__,_|_| |_| |_| |_____/ \__,_|\____|_|\_\ \__|\__,_|_|\___|___/
"

##############################################

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
echo

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo "    1)  build for PC"
		echo "    2)  Kathrein UFS-910"
		echo "    3)  Kathrein UFS-912"
		echo "    4)  Kathrein UFS-913"
		echo "    5)  Kathrein UFS-922"
		echo "    6)  Kathrein UFC-960"
		echo "    7)  Topfield TF77X0 HDPVR"
		echo "    8)  IPBOX55"
		echo "    9)  IPBOX99"
		echo "   10)  IPBOX9900"
		echo "   11)  Cuberevo [ IPBOX 9000 ]"
		echo "   12)  Cuberevo mini [ IPBOX 900 ]"
		echo "   13)  Cuberevo mini2 [ IPBOX 910 ]"
		echo "   14)  Cuberevo 250 [ IPBOX 91 ]"
		echo "   15)  Cuberevo 9500HD [ 7000HD ]"
		echo "   16)  Cuberevo 2000HD"
		echo "   17)  Cuberevo mini_fta [ 200HD ]"
		echo "   18)  Xsarius Alpha [ Cuberevo 3000HD ]"
		echo "   19)  Fortis HDbox [ Fortis FS9000/9200 ]"
		echo "   20)  Octagon SF1008P [ Fortis HS9510 ]"
		echo "   21)  Atevio AV7500 [ Fortis HS8200 ]"
		echo "   22)  Atemio AM520"
		echo "   23)  Atemio AM530"
		echo "   24)  Fortis HS7110"
		echo "   25)  Fortis HS7119"
		echo "   26)  Fortis HS7420"
		echo "   27)  Fortis HS7429"
		echo "   28)  Fortis HS7810A"
		echo "   29)  Fortis HS7819"
		echo "   30)  Edision Argus VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo "   31)  SpiderBox HL-101"
		echo "   32)  SPARK"
		echo "   33)  SPARK7162"
		echo "   34)  B4Team ADB 5800S"
		echo "   35)  Vitamin HD5000"
		echo "   36)  SagemCom 88 series"
		echo "   37)  Ferguson Ariva @Link 200"
		read -p "Select target (1-37)? ";;
esac

case "$REPLY" in
	 1) PLATFORM="pc";BOXTYPE="generic";;
	 2) PLATFORM="sh4";BOXTYPE="ufs910";;
	 3) PLATFORM="sh4";BOXTYPE="ufs912";;
	 4) PLATFORM="sh4";BOXTYPE="ufs913";;
	 5) PLATFORM="sh4";BOXTYPE="ufs922";;
	 6) PLATFORM="sh4";BOXTYPE="ufc960";;
	 7) PLATFORM="sh4";BOXTYPE="tf7700";;
	 8) PLATFORM="sh4";BOXTYPE="ipbox55";;
	 9) PLATFORM="sh4";BOXTYPE="ipbox99";;
	10) PLATFORM="sh4";BOXTYPE="ipbox9900";;
	11) PLATFORM="sh4";BOXTYPE="cuberevo";;
	12) PLATFORM="sh4";BOXTYPE="cuberevo_mini";;
	13) PLATFORM="sh4";BOXTYPE="cuberevo_mini2";;
	14) PLATFORM="sh4";BOXTYPE="cuberevo_250hd";;
	15) PLATFORM="sh4";BOXTYPE="cuberevo_9500hd";;
	16) PLATFORM="sh4";BOXTYPE="cuberevo_2000hd";;
	17) PLATFORM="sh4";BOXTYPE="cuberevo_mini_fta";;
	18) PLATFORM="sh4";BOXTYPE="cuberevo_3000hd";;
	19) PLATFORM="sh4";BOXTYPE="fortis_hdbox";;
	20) PLATFORM="sh4";BOXTYPE="octagon1008";;
	21) PLATFORM="sh4";BOXTYPE="atevio7500";;
	22) PLATFORM="sh4";BOXTYPE="atemio520";;
	23) PLATFORM="sh4";BOXTYPE="atemio530";;
	24) PLATFORM="sh4";BOXTYPE="hs7110";;
	25) PLATFORM="sh4";BOXTYPE="hs7119";;
	26) PLATFORM="sh4";BOXTYPE="hs7420";;
	27) PLATFORM="sh4";BOXTYPE="hs7429";;
	28) PLATFORM="sh4";BOXTYPE="hs7810a";;
	29) PLATFORM="sh4";BOXTYPE="hs7819";;
	30) PLATFORM="sh4";BOXTYPE="hl101";;
	31) PLATFORM="sh4";BOXTYPE="hl101";;
	32) PLATFORM="sh4";BOXTYPE="spark";;
	33) PLATFORM="sh4";BOXTYPE="spark7162";;
	34) PLATFORM="sh4";BOXTYPE="adb_box";;
	35) PLATFORM="sh4";BOXTYPE="vitamin_hd5000";;
	36) PLATFORM="sh4";BOXTYPE="sagemcom88";;
	37) PLATFORM="sh4";BOXTYPE="arivalink200";;
	 *) PLATFORM="sh4";BOXTYPE="atevio7500";;
esac
echo "PLATFORM=$PLATFORM" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

case $2 in
	[1-2]) REPLY=$2;;
	*)	echo -e "\nKernel:"
		echo "   1)  STM 24 P0209 [2.6.32.46]"
		echo "   2)  STM 24 P0217 [2.6.32.71]"
		read -p "Select kernel (1-2)? ";;
esac

case "$REPLY" in
	1)  KERNEL="p0209";;
	2)  KERNEL="p0217";;
	*)  KERNEL="p0217";;
esac
echo "KERNEL=$KERNEL" >> config

##############################################

case $3 in
	[1-4]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1)  optimization for size"
		echo "   2)  optimization normal"
		echo "   3)  Kernel debug"
		echo "   4)  debug / Kernel debug"
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
	*)	echo -e "\nPlayer:"
		echo "   1)  Player 191 test (stmfb-3.1_stm24_0104, for internal testing)"
		echo "   2)  Player 191      (stmfb-3.1_stm24_0104, recommended)"
		read -p "Select player (1-2)? ";;
esac

case "$REPLY" in
	1)	echo "PLAYER_VERSION=191_test" >> config
		echo "MULTICOM_VERSION=324" >> config
		;;
	2)	echo "PLAYER_VERSION=191" >> config
		echo "MULTICOM_VERSION=324" >> config
		;;
	*) ;;
esac

##############################################

case $5 in
	[1-4]) REPLY=$5;;
	*)	echo -e "\nMedia Framework:"
		echo "   1) eplayer3"
		echo "   2) gstreamer"
		echo "   3) use built-in (required for Neutrino)"
		echo "   4) gstreamer+eplayer3 (recommended for OpenPLi)"
		read -p "Select media framework (1-4)? ";;
esac

case "$REPLY" in
	1) MEDIAFW="eplayer3";;
	2) MEDIAFW="gstreamer";;
	3) MEDIAFW="buildinplayer";;
	4) MEDIAFW="gst-eplayer3";;
	*) MEDIAFW="buildinplayer";;
esac
echo "MEDIAFW=$MEDIAFW" >> config

##############################################

case $6 in
	[1-3]) REPLY=$6;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1)  No external LCD"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		read -p "Select external LCD support (1-3)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="none";;
	2) EXTERNAL_LCD="externallcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	*) EXTERNAL_LCD="none";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config
##############################################

case $7 in
	[1-4]) REPLY=$7;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Enigma2"
		echo "   2)  Enigma2 (includes WLAN drivers)"
		echo "   3)  Neutrino"
		echo "   4)  Neutrino (includes WLAN drivers)"
		read -p "Select Image to build (1-4)? ";;
esac

case "$REPLY" in
	1) IMAGE="enigma2";;
	2) IMAGE="enigma2-wlandriver";;
	3) IMAGE="neutrino";;
	4) IMAGE="neutrino-wlandriver";;
	*) IMAGE="neutrino";;
esac
echo "IMAGE=$IMAGE" >> config

##############################################
echo " "
make printenv
echo " "
##############################################
echo "Your build environment is ready :-)"
echo "Your next step could be:"
case "$IMAGE" in
		neutrino*)
		echo "  make yaud-neutrino-mp-cst-next"
		echo "  make yaud-neutrino-mp-cst-next-ni"
		echo "  make yaud-neutrino-hd2";;
		enigma2*)
		echo "  make yaud-enigma2";;
		*)
esac
echo " "
