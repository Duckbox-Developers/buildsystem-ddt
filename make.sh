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
	echo "Parameter 1: target system (1-38)"
	echo "Parameter 2: kernel (1-2) for sh4 cpu"
	echo "Parameter 3: optimization (1-4)"
	echo "Parameter 4: Media Framework (1-2)"
	echo "Parameter 5: Image Neutrino (1-2)"
	echo "Parameter 6: Neutrino variant (1-4)"
	exit
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 5[0-9]) REPLY=$1;;
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
		echo "  Various sh4-based receivers"
		echo "   31)  Edision Argus VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo "   32)  SpiderBox HL-101"
		echo "   33)  B4Team ADB 5800S"
		echo "   34)  Vitamin HD5000"
		echo "   35)  SagemCom 88 series"
		echo "   36)  Ferguson Ariva @Link 200"
		#echo "   37)  Pace HDS-7241 (stm 217 only)"
		echo
		echo "  arm-based receivers"
		echo "   50)  Vu Solo4K"
		echo "   51)  Mut@nt HD51"
		echo "   "
		echo
		read -p "Select target (1-59)? ";;
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
	37) BOXARCH="sh4";BOXTYPE="pace7241";;
	50) BOXARCH="arm";BOXTYPE="vusolo4k";;
	51) BOXARCH="arm";BOXTYPE="hd51";;
	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

if [ $BOXTYPE == 'hd51' ]; then

		echo -e "\n*** boxmode=1 (Standard) ***"
		echo -e "+++ Features +++"
		echo -e "3840x2160p60 10-bit HEVC, 3840x2160p60 8-bit VP9, 1920x1080p60 8-bit AVC,\nMAIN only (no PIP), Limited display usages, UHD only (no SD),\nNo multi-PIP, No transcoding"
		echo -e "--- Restrictions ---"
		echo -e "Decoder 0: 3840x2160p60 10-bit HEVC, 3840x2160p60 8-bit VP9, 1920x1080p60 8-bit AVC"
		echo -e "OSD Grafic 0: 1080p60 32 bit ARGB"
		echo -e "Display 0 Encode Restrictions: 3840x2160p60 12-bit 4:2:0 (HDMI),\n3840x2160p60 12-bit 4:2:2 (HDMI), 3840x2160p60 8-bit 4:4:4 (HDMI),\n1920x1080p60 (component), Only one display format at a time"
		echo -e "\n*** boxmode=12 (Experimental) ***"
		echo -e "+++ Features +++"
		echo -e "3840x2160p50 10-bit decode for MAIN, 1080p25/50i PIP support,\n UHD display only, No SD display, No transcoding"
		echo -e "--- Restrictions ---"
		echo -e "Decoder 0: 3840x2160p50 10-bit HEVC, 3840x2160p50 8-bit VP9,\n1920x1080p50 8-bit AVC/MPEG"
		echo -e "Decoder 1: 1920x1080p25/50i 10-bit HEVC, 1920x1080p25/50i 8-bit VP9/AVC/MPEG2, 3840x2160p50"
		echo -e "OSD Graphic 0 (UHD): 1080p50 32-bit ARGB"
		echo -e "Window 0 (MAIN/UHD): Limited display capabilities, 1080i50 10-bit de-interlacing"
		echo -e "Window 1 (PIP/UHD): Up to 1/2 x 1/2 screen display, 576i50 de-interlacing"
		echo -e "Display 0 (UHD) Encode Restrictions: 3840x2160p50"

case $2 in
	[1-2]) REPLY=$2;;
	*)	echo -e "\nBoxmode:"
		echo "   1)   1     (default)"
		echo "   2)  12 PIP (PIP not supported by neutrino yet)"
		read -p "Select mode (1-2)? ";;
esac

case "$REPLY" in
	1)  HD51_BOXMODE="1";;
	2)  HD51_BOXMODE="12";;
	*)  HD51_BOXMODE="1";;
esac
echo "HD51_BOXMODE=$HD51_BOXMODE" >> config
fi

##############################################

if [ $BOXARCH == "sh4" ]; then

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

fi

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
	*)	echo -e "\nMedia Framework:"
		echo "   1) libeplayer3"
		echo "   2) gstreamer"
		read -p "Select media framework (1-2)? ";;
esac

case "$REPLY" in
	1) MEDIAFW="buildinplayer";;
	2) MEDIAFW="gstreamer";;
	*) MEDIAFW="buildinplayer";;
esac
echo "MEDIAFW=$MEDIAFW" >> config

##############################################

case $5 in
	[1-2]) REPLY=$5;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Neutrino"
		echo "   2)  Neutrino (includes WLAN drivers sh4)"
		read -p "Select Image to build (1-2)? ";;
esac

case "$REPLY" in
	1) IMAGE="neutrino";;
	2) IMAGE="neutrino-wlandriver";;
	*) IMAGE="neutrino";;
esac
echo "IMAGE=$IMAGE" >> config

##############################################

case $6 in
	[1-4]) REPLY=$6;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo "   1)  neutrino-mp-ddt    [ arm/sh4 ]"
		echo "   2)  neutrino-mp-ni     [ arm     ]"
		echo "   3)  neutrino-mp-tangos [ arm/sh4 ]"
		echo "   4)  neutrino-hd2       [ arm/sh4 ]"
		read -p "Select Image to build (1-4)? ";;
esac

case "$REPLY" in
	1) FLAVOUR="neutrino-mp-ddt";;
	2) FLAVOUR="neutrino-mp-ni";;
	3) FLAVOUR="neutrino-mp-tangos";;
	4) FLAVOUR="neutrino-hd2";;
	*) FLAVOUR="neutrino-mp-ddt";;
esac
echo "FLAVOUR=$FLAVOUR" >> config

##############################################
echo " "
make printenv
##############################################
echo "Your next step could be:"
case "$FLAVOUR" in
	neutrino-mp*)
		echo "  make neutrino-mp"
		echo "  make neutrino-mp-plugins";;
	neutrino-hd2*)
		echo "  make neutrino-hd2"
		echo "  make neutrino-hd2-plugins";;
	*)
		echo "  make flashimage"
		echo "  make ofgimage";;
esac
echo " "
