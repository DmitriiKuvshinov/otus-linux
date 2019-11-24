#!/bin/bash
LOG_FILE="../log/access-4560-644067.log"
cp $LOG_FILE "./log.tmp"
LOG_FILE="./log.tmp"
DATE=$(date +"%d.%b.%Y:%H:%M:%S")
RESULT_FILE="./links_"$DATE".log"

echo "$DATE" > $RESULT_FILE
cat ../log/access-4560-644067.log | awk '{print $7}' | sort -r | uniq -c | sort -r | head -10

rm $LOG_FILE
cat $RESULT_FILE
