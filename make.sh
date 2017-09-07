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
	echo "Parameter 1: target system (1-36)"
	echo "Parameter 2: kernel (1-2)"
	echo "Parameter 3: optimization (1-4)"
	echo "Parameter 4: player (1-2)"
	echo "Parameter 5: Media Framework (1-4)"
	echo "Parameter 6: External LCD support (1-3)"
	echo "Parameter 7: Image (Enigma=1/2 Neutrino=3/4 (1-4)"
	exit
fi

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

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-7]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo
		echo "  Kathrein             Fortis"
		echo "    1)  UFS-910          7)  FS9000 / FS9200 (formerly Fortis HDbox)"
		echo "    2)  UFS-912          8)  HS9510          (formerly Octagon SF1008P)"
		echo "    3)  UFS-913          9)  HS8200          (formerly Atevio AV7500)"
		echo "    4)  UFS-922         10)  HS7110"
		echo "    5)  UFC-960         11)  HS7119"
		echo "                        12)  HS7420"
		echo "  Topfield              13)  HS7429"
		echo "    6)  TF77X0 HDPVR    14)  HS7810A"
		echo "                        15)  HS7819"
		echo
		echo "  AB IPBox             Cuberevo"
		echo "   16)  55HD            19)  id."
		echo "   17)  99HD            20)  mini"
		echo "   18)  9900HD          21)  mini2"
		echo "   19)  9000HD          22)  250HD"
		echo "   20)  900HD           23)  9500HD / 7000HD"
		echo "   21)  910HD           24)  2000HD"
		echo "   22)  91HD            25)  mini_fta / 200HD"
		echo "                        26)  3000HD / Xsarius Alpha"
		echo
		echo "  Fulan                Atemio"
		echo "   27)  Spark           29)  AM520"
		echo "   28)  Spark7162       30)  AM530"
		echo
		echo "  Various"
		echo "   31)  Edision Argus VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo "   32)  SpiderBox HL-101"
		echo "   33)  B4Team ADB 5800S"
		echo "   34)  Vitamin HD5000"
		echo "   35)  SagemCom 88 series"
		echo "   36)  Ferguson Ariva @Link 200"
		echo
		echo "   37)  armbox for internal testing"
		echo
		read -p "Select target (1-37)? ";;
esac

case "$REPLY" in
	 1) BOXARCH="sh4";BOXTYPE="ufs910";;
	 2) BOXARCH="sh4";BOXTYPE="ufs912";;
	 3) BOXARCH="sh4";BOXTYPE="ufs913";;
	 4) BOXARCH="sh4";BOXTYPE="ufs922";;
	 5) BOXARCH="sh4";BOXTYPE="ufc960";;
	 6) BOXARCH="sh4";BOXTYPE="tf7700";;
	 7) BOXARCH="sh4";BOXTYPE="fortis_hdbox";;
	 8) BOXARCH="sh4";BOXTYPE="octagon1008";;
	 9) BOXARCH="sh4";BOXTYPE="atevio7500";;
	10) BOXARCH="sh4";BOXTYPE="hs7110";;
	11) BOXARCH="sh4";BOXTYPE="hs7119";;
	12) BOXARCH="sh4";BOXTYPE="hs7420";;
	13) BOXARCH="sh4";BOXTYPE="hs7429";;
	14) BOXARCH="sh4";BOXTYPE="hs7810a";;
	15) BOXARCH="sh4";BOXTYPE="hs7819";;
	16) BOXARCH="sh4";BOXTYPE="ipbox55";;
	17) BOXARCH="sh4";BOXTYPE="ipbox99";;
	18) BOXARCH="sh4";BOXTYPE="ipbox9900";;
	19) BOXARCH="sh4";BOXTYPE="cuberevo";;
	20) BOXARCH="sh4";BOXTYPE="cuberevo_mini";;
	21) BOXARCH="sh4";BOXTYPE="cuberevo_mini2";;
	22) BOXARCH="sh4";BOXTYPE="cuberevo_250hd";;
	23) BOXARCH="sh4";BOXTYPE="cuberevo_9500hd";;
	24) BOXARCH="sh4";BOXTYPE="cuberevo_2000hd";;
	25) BOXARCH="sh4";BOXTYPE="cuberevo_mini_fta";;
	26) BOXARCH="sh4";BOXTYPE="cuberevo_3000hd";;
	27) BOXARCH="sh4";BOXTYPE="spark";;
	28) BOXARCH="sh4";BOXTYPE="spark7162";;
	29) BOXARCH="sh4";BOXTYPE="atemio520";;
	30) BOXARCH="sh4";BOXTYPE="atemio530";;
	31) BOXARCH="sh4";BOXTYPE="hl101";;
	32) BOXARCH="sh4";BOXTYPE="hl101";;
	33) BOXARCH="sh4";BOXTYPE="adb_box";;
	34) BOXARCH="sh4";BOXTYPE="vitamin_hd5000";;
	35) BOXARCH="sh4";BOXTYPE="sagemcom88";;
	36) BOXARCH="sh4";BOXTYPE="arivalink200";;
	37) BOXARCH="arm";BOXTYPE="armbox";;
	 *) BOXARCH="sh4";BOXTYPE="atevio7500";;
esac
echo "BOXARCH=$BOXARCH" > config
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
	1)  KERNEL_STM="p0209";;
	2)  KERNEL_STM="p0217";;
	*)  KERNEL_STM="p0217";;
esac
echo "KERNEL_STM=$KERNEL_STM" >> config

##############################################

case $3 in
	[1-4]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1)  optimization for size"
		echo "   2)  optimization normal"
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
	*)	echo -e "\nPlayer:"
		echo "   1)  Player 191 (stmfb-3.1_stm24_0104, for internal testing)"
		echo "   2)  Player 191 (stmfb-3.1_stm24_0104, recommended)"
		read -p "Select player (1-2)? ";;
esac

case "$REPLY" in
	1)	echo "PLAYER_VER=191_test" >> config
		echo "MULTICOM_VER=324" >> config
		;;
	2)	echo "PLAYER_VER=191" >> config
		echo "MULTICOM_VER=324" >> config
		;;
	*) ;;
esac

##############################################

case $5 in
	[1-4]) REPLY=$5;;
	*)	echo -e "\nMedia Framework:"
		echo "   1) eplayer3"
		echo "   2) gstreamer"
		echo "   3) use built-in       (required for Neutrino)"
		echo "   4) gstreamer+eplayer3 (required for OpenPLi)"
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
		echo "   2)  Enigma2  (includes WLAN drivers)"
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
		echo "  make yaud-neutrino-mp-cst-next-plugins"
		echo "  make yaud-neutrino-mp-cst-next-ni"
		echo "  make yaud-neutrino-mp-cst-next-ni-plugins"
		echo "  make yaud-neutrino-hd2"
		echo "  make yaud-neutrino-hd2-plugins";;
		enigma2*)
		echo "  make yaud-enigma2";;
		*)
esac
echo " "
