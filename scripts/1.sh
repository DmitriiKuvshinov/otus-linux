#!/bin/bash
LOG_FILE="../log/access-4560-644067.log"
cp $LOG_FILE "./log.tmp"
LOG_FILE="./log.tmp"
DATE=$(date +"%d.%b.%Y:%H:%M:%S")
RESULT_FILE="./result_"$DATE".log"

echo "$DATE" > $RESULT_FILE
cat $LOG_FILE | awk '{print $1}' | uniq -c | sort -r | head -10 >> $RESULT_FILE

rm $LOG_FILE
cat $RESULT_FILE
