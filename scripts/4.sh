#!/bin/bash
LOG_FILE="../log/access-4560-644067.log"
cp $LOG_FILE "./log.tmp"
LOG_FILE="./log.tmp"
DATE=$(date +"%d.%b.%Y:%H:%M:%S")
RESULT_FILE="./return_"$DATE".log"

echo "$DATE" > $RESULT_FILE
cat $LOG_FILE | awk '{print $9}' | sort -r | uniq -c | sort -r >> $RESULT_FILE

rm $LOG_FILE
cat $RESULT_FILE
