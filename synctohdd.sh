#!/bin/bash
#DISK=/dev/sde1
MOUNTPOINT=/media/backup
SOURCE=/home/shares/clientdata/
mount UUID=4de4c4a6-c27d-4e85-8021-cc14c59b0a6b ${MOUNTPOINT}
if ! [ -e ${MOUNTPOINT}/dummy ]
then
        echo "Backup disk not connected on `date`" >> /var/www/logs/didnothappen
        echo "Backup disk not connected on `date`" | mail -c redalert@aware.co.in -s "Backup disk notification" krishna@upadhyaassociates.com 
        exit
fi

# first, delete the oldest backup

if [ -d $MOUNTPOINT/backup.5 ]
then
        rm -rf $MOUNTPOINT/backup.5
fi

# now, shift the middle backups
if [ -d $MOUNTPOINT/backup.4 ]
then
        mv $MOUNTPOINT/backup.4 $MOUNTPOINT/backup.5
fi

if [ -d $MOUNTPOINT/backup.3 ]
then
        mv $MOUNTPOINT/backup.3 $MOUNTPOINT/backup.4
fi

if [ -d $MOUNTPOINT/backup.2 ]
then
        mv $MOUNTPOINT/backup.2 $MOUNTPOINT/backup.3
fi

if [ -d $MOUNTPOINT/backup.1 ]
then
        mv $MOUNTPOINT/backup.1 $MOUNTPOINT/backup.2
fi


# make a hard link copy of latest snapshot
if [ -d $MOUNTPOINT/backup.0 ]
then
        cp -al $MOUNTPOINT/backup.0 $MOUNTPOINT/backup.1
fi

rsync --stats -av --numeric-ids --delete ${SOURCE} ${MOUNTPOINT}/backup.0/ > /var/www/logs/sync-`date +%F`.log
rsync -av --stats /etc ${MOUNTPOINT}/ > /var/www/logs/etcsync-`date +%F`.log
# update the time on the latest snapshot
touch ${MOUNTPOINT}/backup.0

umount ${MOUNTPOINT}

echo "Backup script on upadhyaassociates server running on  `date`" | mail -s "Backup disk notification" support@aware.co.in
