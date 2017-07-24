#!/bin/sh
#DISK=/dev/sdf1
MOUNTPOINT=/media/backup
SOURCE=/home/vmail/vmail1
mount UUID=4de4c4a6-c27d-4e85-8021-cc14c59b0a6b ${MOUNTPOINT}

# create new backup for advith
duplicity --no-encryption /home/vmail/vmail1/advithconsulting.in file:///media/backup/mailsbkp/advith

# create new backup for upadhya
duplicity --no-encryption /home/vmail/vmail1/upadhyaassociates.com file:///media/backup/mailsbkp/upadhya

umount ${MOUNTPOINT}
