#!/bin/sh

echo Starting wlan0

wpa_cli terminate
sleep 2
wpa_supplicant -D wext -c /etc/wpa_supplicant.conf -i wlan0 -B
sleep 8
