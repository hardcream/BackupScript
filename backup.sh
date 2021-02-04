#!/bin/bash
########## Configuration ############
BACKUPFILES=" /etc/ /home/ /data/ " # zu sichernde Verzeichnisse
DIR="/backup/full_backup/" # Backup-Verzeichnis
INC_DIR="/backup/incremental_backup/"
AGE=$(find "/backup/full_backup/" -mmin +1) # -1 = Nicht aelter als 24 Stunden, -2 = 48 ...
SNAP="snapshot.file"
OLD_DIR="/backup/old_backup/old_full_backup/"
OLD_INC_DIR="/backup/old_backup/old_inc_backup/"

DATE=$(date +%Y-%m-%d-%T) # Datum im Format YearMonthDay

TAR=/bin/tar

TAROPTIONS="czgPf"



FILE=backup-$DATE.tar.gz # Dateiname der Backup-Datei
INC_FILE=incremental-$DATE.tar.gz
echo "#######################"
echo Creating Backup.
echo PLEASE WAIT!
sleep 2
NUM=$(ls "$DIR" | wc -l)
if [ "$NUM" -gt 1 ]
then

        if [[ $AGE == *"backup"* ]]
         then
                echo Full Backup is older than 7 days
                echo Removing old Snapshot file
                sleep 2
		if  test /backup/old_full_backup/snapshot.file
		 then
			rm -rf /backup/old_backup/old_full_backup/snapshot.file
			echo Snapshot removed
		else
			echo No Snapshot found
		fi
		echo Old snapshot removed
		sleep 1 
                mv /backup/full_backup/snapshot.file  /backup/old_backup/old_full_backup/
                echo current snapshot moved to old backup folder
                echo Creating new full Backup
		cd /backup/full_backup/ || exit
                sleep 3
                $TAR $TAROPTIONS $SNAP "$DIR"/"$FILE"  $BACKUPFILES
                sleep 3
                echo "####################"
                echo Moving old full Backup
		cd /backup/full_backup/ || exit
                OLD_FILE=$(ls -t | tail -1)
                echo "$OLD_FILE"
                cp "$OLD_FILE" /backup/old_backup/old_full_backup/
		sleep 2
                rm $OLD_FILE
                OLD_NUM=$(ls "$OLD_DIR" | wc -l)

                while [ "$OLD_NUM" -gt 1 ]
                do
                        OLD_NUM=$(( OLD_NUM -1 ))
			cd /backup/old_backup/old_full_backup || exit
                        OLD_FILE=$(ls -t | tail -1)
                        rm "$OLD_FILE"
                done

                echo Moving old incremental Backups
		cd /backup/incremental_backup/ || exit
                cp -a /backup/incremental_backup/*  /backup/old_backup/old_inc_backup
                sleep 3
                rm -rf /backup/incremental_backup/*
                INC_NUM=$(ls "$OLD_INC_DIR" | wc -l)

                while [ "$INC_NUM" -gt 5 ]
                do
                        INC_NUM=$(( INC_NUM - 1 ))
			cd /backup/old_backup/old_inc_backup || exit 
                        INC_OLD_FILE=$(ls -t | tail -1)
                        rm -rf  "$INC_OLD_FILE"
                done

        else
                echo Creating incremental Backup
                echo "##########################"
                sleep 3
                cd "$INC_DIR" || exit
                $TAR $TAROPTIONS $SNAP "$INC_DIR"/"$INC_FILE"  $BACKUPFILES
        fi

else
        echo Creating new full Backup
        sleep 3
        cd "$DIR" || exit
        $TAR $TAROPTIONS $SNAP "$DIR"/"$FILE"  $BACKUPFILES

fi

