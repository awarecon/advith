#!/bin/bash
MOUNTPOINT=/media/backup
BACKUPDIR=$(date +%b-%d-%y)
ARCHIVEPATH=/media/backup/mailarchive
ADPATH=/home/vmail/vmail1/advithconsulting.in
UPDPATH=/home/vmail/vmail1/upadhyaassociates.com

mount UUID=4de4c4a6-c27d-4e85-8021-cc14c59b0a6b ${MOUNTPOINT}

if ! [ -e ${MOUNTPOINT}/dummy ]
then
        echo "Backup disk not connected on `date`" >> /var/www/logs/didnothappen
        echo "Backup disk not connected on `date`" | mail -s "Backup disk notification" redalert@aware.co.in
        exit
fi

/etc/init.d/postfix stop
/etc/init.d/crond stop
killall fetchmail

mkdir ${ARCHIVEPATH}/${BACKUPDIR}

mkdir -p ${ARCHIVEPATH}/${BACKUPDIR}/advith/{receive,sent}
mkdir -p ${ARCHIVEPATH}/${BACKUPDIR}/upadhya/{receive,sent}

find ${ADPATH} -type d -name "*received*" > /tmp/adreceivelist
find ${ADPATH} -type d -name "*sent*" > /tmp/adsentlist

find ${UPDPATH} -type d -name "*received*" > /tmp/updreceivelist
find ${UPDPATH} -type d -name "*sent*" > /tmp/updsentlist

for i in `cat /tmp/adreceivelist`
do
	j=`echo ${i} | awk -F"/" '{print $9}' | cut -f 1 -d"-"`
        cd ${i}
	tar -pcvzf ${j}-received-Maildir.tar.gz Maildir
	rsync -av --stats ${j}-received-Maildir.tar.gz ${ARCHIVEPATH}/${BACKUPDIR}/advith/receive/
	rm ${j}-received-Maildir.tar.gz
	rm ${i}/Maildir/new/*
	rm ${i}/Maildir/cur/*
	rm ${i}/Maildir/tmp/*
done

for i in `cat /tmp/adsentlist`
do
	j=`echo ${i} | awk -F"/" '{print $9}' | cut -f 1 -d"-"`
        cd ${i}
	tar -pcvzf ${j}-sent-Maildir.tar.gz Maildir
	rsync -av --stats ${j}-sent-Maildir.tar.gz ${ARCHIVEPATH}/${BACKUPDIR}/advith/sent/
	rm ${j}-sent-Maildir.tar.gz
	rm ${i}/Maildir/new/*
	rm ${i}/Maildir/cur/*
	rm ${i}/Maildir/tmp/*
done

for i in `cat /tmp/updreceivelist`
do
	j=`echo ${i} | awk -F"/" '{print $9}' | cut -f 1 -d"-"`
        cd ${i}
	tar -pcvzf ${j}-received-Maildir.tar.gz Maildir
	rsync -av --stats ${j}-received-Maildir.tar.gz ${ARCHIVEPATH}/${BACKUPDIR}/upadhya/receive/
	rm ${j}-received-Maildir.tar.gz
	rm ${i}/Maildir/new/*
	rm ${i}/Maildir/cur/*
	rm ${i}/Maildir/tmp/*
done

for i in `cat /tmp/updsentlist`
do
	j=`echo ${i} | awk -F"/" '{print $9}' | cut -f 1 -d"-"`
        cd ${i}
	tar -pcvzf ${j}-sent-Maildir.tar.gz Maildir
	rsync -av --stats ${j}-sent-Maildir.tar.gz ${ARCHIVEPATH}/${BACKUPDIR}/upadhya/sent/
	rm ${j}-sent-Maildir.tar.gz
	rm ${i}/Maildir/new/*
	rm ${i}/Maildir/cur/*
	rm ${i}/Maildir/tmp/*
done

/etc/init.d/postfix start
/etc/init.d/crond start
rsync --stats -av --numeric-ids --delete /etc/ /media/backup/etcbackup/ > /media/backup/etcbackup/etcsync.log
echo "Monthly backup successfully completed at Adivth Consultants" | mail -s "Advith backup" support@aware.co.in
umount ${MOUNTPOINT}
