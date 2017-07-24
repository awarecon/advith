#!/bin/sh
DISK=/dev/sdf1
MOUNTPOINT=/media/backup/
SOURCE=/home/vmail/vmail1
mount UUID=4de4c4a6-c27d-4e85-8021-cc14c59b0a6b ${MOUNTPOINT}

# create new backup
tar -czPf ${MOUNTPOINT}/mailbackups/mailbackup-`date +"%m_%d_%Y"`.tar.gz ${SOURCE}  

# delete old backup
find ${MOUNTPOINT}/mailbackups -mtime +7 -type f -delete

umount ${MOUNTPOINT}
