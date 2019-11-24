#!/bin/bash

ERRORS_FILE="../web-errors"
cp "../log/access-4560-644067.log" "./log.tmp"
LOG_FILE="./log.tmp"
DATE=$(date +"%d.%b.%Y:%H:%M:%S")
RESULT_FILE="./error_"$DATE".log"
echo "$DATE" > $RESULT_FILE

while read -r line; do

STATUS=$(echo "$line" | awk '{print $9}')
if grep -q $STATUS $ERRORS_FILE; then
echo "ERROR: $line" >> $RESULT_FILE
else echo "not error"
fi;

done < $LOG_FILE

rm $LOG_FILE
