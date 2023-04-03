#!/bin/bash
logfile=$1
s3_bucket=$2
twelve_hour_in_seconds=43200
current_date=$(date +"%s")


#Traversing files in folder to compare the date
for file in ./$logfile/*;
do
  file_date=$(stat -c '%Y' $file)
  difference=$(($current_date - $file_date))
  if [ $difference -gt $twelve_hour_in_seconds ]; then
        echo "Moving into folder which has to be deleted"
        mv ./$file ./folder_to_be_deleted/
  fi
done

#Zipping the folder
if [ $? -eq 0 ]; then
    echo " Zipping the old logs"
    zip -r old_logs.zip folder_to_be_deleted/
else
    echo "Cant zip"
fi

#Transfering the archive to S3 bucket
if [ $? -eq 0 ]; then
    echo " Transferring to S3 Bucket"
    aws s3 cp ./old_logs.zip s3://$s3_bucket
else
    echo "Cant Upload to s3"
fi