#!/bin/bash

source `dirname $BASH_SOURCE`/config

DATA_UPLOAD_FILES=()
MYSQL_UPLOAD_FILES=()

# Backup files and databases
for dir in "${BACKUP_DIRS[@]}"
do
    BACKUP_FILE=$TMP_DIR/${dir//[^a-zA-Z0-9]/_}-`date +%Y%m%d-%H%M%S`.tar.gz
    tar czvPf $BACKUP_FILE $dir
    DATA_UPLOAD_FILES+=($BACKUP_FILE)
done

if [ "${#BACKUP_DB[@]}" = 0 ]
then
    BACKUP_FILE=$TMP_DIR/all-`date +%Y%m%d-%H%M%S`.sql.gz

    if [ -z "$MYSQL_PASS" ]
    then
        mysqldump -u $MYSQL_USER --all-databases | gzip > $BACKUP_FILE
    else
        mysqldump -u $MYSQL_USER -p$MYSQL_PASS --all-databases | gzip > $BACKUP_FILE
    fi

    echo "Dumped all databases"

    MYSQL_UPLOAD_FILES+=($BACKUP_FILE)

else
    for db in "${BACKUP_DB[@]}"
    do
        BACKUP_FILE=$TMP_DIR/${db}-`date +%Y%m%d-%H%M%S`.sql.gz

        if [ -z "$MYSQL_PASS" ]
        then
            mysqldump -u $MYSQL_USER $db | gzip > $BACKUP_FILE
        else
            mysqldump -u $MYSQL_USER -p$MYSQL_PASS $db | gzip > $BACKUP_FILE
        fi

        echo Dumped database: $db

        MYSQL_UPLOAD_FILES+=($BACKUP_FILE)
    done
fi


## Upload files to S3
for file in "${DATA_UPLOAD_FILES[@]}"
do
    $AWS_BIN s3 cp $file s3://$BUCKET/$HOSTNAME/data/
    echo Uploaded $file...

    rm -f $file
    echo Removed $file...
done

for file in "${MYSQL_UPLOAD_FILES[@]}"
do
    $AWS_BIN s3 cp $file s3://$BUCKET/$HOSTNAME/mysql/
    echo Uploaded $file...

    rm -f $file
    echo Removed $file...
done
