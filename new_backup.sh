#!/bin/bash

TAR=/bin/tar
BACKUPDIR=" /etc/ /home/ /data/"
DATE=$(date +%a-%Y-%m-%d-%T)
AGE=$(find "/backup/new_backup/" -mmin +10075)


COUNT=$(ls /backup/new_backup/ | wc -l)
if [[ $AGE == *"backup.snar"* ]]
then

                        echo Backup ist alt und wird ersetzt
                        echo Verschiebe alte Backupdateien und Metafile
                        sleep 2
                        mv /backup/new_backup/* /backup/old_backup/
                        echo "###################################"
                        echo Erstelle neues Full-Backup
                        cd /backup/new_backup/ || exit
                        sleep 2
                        $TAR -czgvf backup.snar /backup/new_backup/backup."$DATE".tar.gz $BACKUPDIR

                        CONT=$(ls /backup/old_backup/ | wc -l)
                        if [ "$CONT" -gt 6 ]
                        then
                                        echo Old Backupfolder is full
                                        echo Removing unused Backups
                                        while [ "$CONT" -gt 6 ]
                                        do
                                                        CONT=$(( CONT - 1 ))
                                                        cd /backup/old_backup/ || exit
                                                        OLD_FILE=$(ls -t | tail -1)
                                                        rm -rf  "$OLD_FILE"
                                        done
                                        echo Removing old Backups finished

                        fi
elif [ "$COUNT" -ge 1 ]
then
	echo Creating incremental Backup
	sleep 1
	$TAR czgvvPf backup.snar /backup/new_backup/backup."$DATE".tar.gz $BACKUPDIR



else

        echo "###################################"
        echo Creating intial Full-Backup
        echo "###################################"
        cd /backup/new_backup/
        sleep 2
        $TAR czgvvPf backup.snar /backup/new_backup/backup."$DATE".tar.gz $BACKUPDIR

fi

