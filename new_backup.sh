#!/bin/bash

TAR=/bin/tar
#Angeben der Ordner von denen ein Backup erstellt werden soll
BACKUPDIR=" /etc/ /home/ /data/"

# Erstellt einen Zeitstempel damit die Backups sortiert werden können
DATE=$(date +%a-%Y-%m-%d-%T) 

# Überprüft ob der Snapshot älter als eine x Minuten ist -> Falls ja, findet der Befehl die Snapshot Datei
AGE=$(find "/backup/new_backup/" -mmin +1300) 

# Speichert die Menge der vorhandenen Backups im "/backup/new_backup/" Ordner
COUNT=$(ls /backup/new_backup/ | wc -l)

# Überprüft, ob der Snapshot zu alt ist
if [[ $AGE == *"backup.snar"* ]]
# Wenn die Expression zutrifft dann, 
then

                        echo Backup ist alt und wird ersetzt
                        echo Verschiebe alte Backupdateien und Metafile
                        sleep 2
			# Verschiebt alle Dateien aus der alten Woche von "backup/new_backup" nach  "/backup/old_backup" Ordner
                        mv /backup/new_backup/* /backup/old_backup/
                        echo "###################################"
                        echo Erstelle neues Full-Backup
			# Wechselt in den "/backup/new_backup" Ordner, falls dieser nicht existiert beendet sich das Script
                        cd /backup/new_backup/ || exit
                        sleep 2
			# Erstellen des Full-Backups mit dem entsprechenden Zeitstempel und Pfaden
			# Die Optionen geben and c=Create  z=read wirte gzip g= Erstellt eine Incremental Datei und in Incremental Format f=Verwendet Archive Datei P=Verhindert das entfernen von "/" der Dateinamen 
			$TAR czgPf backup.snar /backup/new_backup/full-backup."$DATE".tar.gz $BACKUPDIR
			
			# Zählt die Dateien im "/backup/old_backup" Ordner
                        CONT=$(ls /backup/old_backup/ | wc -l)

			# Wenn mehr als 7 Dateien vorhanden sind
                        if [ "$CONT" -gt 7 ]
                        then
                                        echo Old Backupfolder is full
                                        echo Removing unused Backups
					# Entfernt solange die älteste Datei aus dem "/backup/old_backup" Ordner bis nur noch die kürzlich verschobenen Dateien vorhanden sind
					# Wird erst ab der 3. Woche ausgelöst
                                        while [ "$CONT" -gt 7 ]
                                        do
                                                        CONT=$(( CONT - 1 ))
                                                        cd /backup/old_backup/ || exit
							# Filtert nach der ältesten Datei im Ordner und löscht diese
                                                        OLD_FILE=$(ls -t | tail -1)
                                                        rm -rf  "$OLD_FILE"
                                        done
                                        echo Removing old Backups finished

                        fi

# Falls bereits ein Full-Backup besteht wird ein Incremental Backup erstellt
elif [ "$COUNT" -ge 1 ]
then
	echo Creating incremental Backup
	cd /backup/new_backup || exit
	sleep 1
	# Backup.snar wird angepasst 
	$TAR czgPf backup.snar /backup/new_backup/inc-backup."$DATE".tar.gz $BACKUPDIR


# Falls noch kein Full-Backup besteht wird hier intial eins erstellt
else

        echo "###################################"
        echo Creating intial Full-Backup
        echo "###################################"
        cd /backup/new_backup/
        sleep 2
        $TAR czgPf backup.snar /backup/new_backup/full-backup."$DATE".tar.gz $BACKUPDIR

fi

