#!/bin/sh

# flashing backuped bootargs to /dev/mtd2

echo 'Flashing original bootargs'

if [ -e /var/mtd2.bak ] then
dd if=/var/mtd2.bak of=/dev/mtdblock2	
fi
    
sleep 3
    
reboot -f