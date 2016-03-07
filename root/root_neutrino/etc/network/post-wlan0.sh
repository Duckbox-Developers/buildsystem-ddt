#!/bin/sh

echo Stopping wlan0

wpa_cli terminate
sleep 2
