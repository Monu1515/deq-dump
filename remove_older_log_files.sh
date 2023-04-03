#!/bin/bash

source_path="$1"
destination_path="$2"
s3_bucket="log-backup-test-rahul"
current_date=$(date +"%d_%m-%Y")
threshold="30" #threshold in days

while [ 1 ]
do

	###create script logging file
	logfile="/tmp/logfile-$current_date"
	:> $logfile

	###create tar file for older logs before 30 days
	find $source_path -type f -mtime +$threshold -print0 | xargs -0 tar -cvzf $destination_path >> $logfile

	###get return code of tar file creation
	ret=$?

	if [ "$ret" == "0" ] ; then
		echo "tar created successfully" >> $logfile
		###upload tar file to s3
		aws s3 cp "$destination_path" s3://$s3_bucket
		ret2="$?"

		if [ "$ret2" == "0" ]; then
			echo "file uploaded to s3" >> $logfile

			###delete older logs file
			find $source_path -type f -mtime +$threshold -exec rm -f {} ';'
			ret3="$?"
			if [ "$ret3" == "0" ]; then
				echo "older files deleted" >> $logfile
			else
				echo "failed to delete older files" >> $logfile
			fi 

		else
			echo "failed to upload file to s3" >> $logfile
		fi

	else
		echo "error occured while tar creation" >> $logfile
	fi  


	break
done
