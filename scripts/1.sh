#!/bin/bash
LockFile=/tmp/main.lock

if [ -f ${LockFile} ]; then
echo -e "File ${LockFile} still exist, now exiting... \nEnter to unlock: rm -rf ${LockFile}" | sendmail root@localhost
exit 0
else
touch ${LockFile}
echo "LockFile ${LockFile} now creating..."
LOG_FILE="../log/access-4560-644067.log"
cp $LOG_FILE "./log.tmp"
LOG_FILE="./log.tmp"
DATE=$(date +"%d.%b.%Y:%H:%M:%S")
DATE_last=$(cat $RESULT_FILE | head -1)
RESULT_FILE="./report.log"
ERRORS_FILE="../web-errors"

## ТОП 10 IP адресов
echo "Отчет за период с $DATE_last по $DATE" > $RESULT_FILE
cat $LOG_FILE | awk '{print $1}' | uniq -c | sort -r | head -10 >> $RESULT_FILE
echo "===========================================" >> $RESULT_FILE

##  ТОП 10 запросов
cat ../log/access-4560-644067.log | awk '{print $7}' | sort -r | uniq -c | sort -r | head -10 >> $RESULT_FILE
echo "===========================================" >> $RESULT_FILE

## Список ответов веб-сервера с ошибками
while read -r line; do
STATUS=$(echo "$line" | awk '{print $9}')
if grep -q $STATUS $ERRORS_FILE; then
echo "ERROR: $line" >> $RESULT_FILE
fi;
done < $LOG_FILE

echo "===========================================" >> $RESULT_FILE

## ТОП 10 ответов сервера
cat $LOG_FILE | awk '{print $9}' | sort -r | uniq -c | sort -r >> $RESULT_FILE

rm $LOG_FILE
sendmail root@localhost < $RESULT_FILE

rm -f /tmp/the.lock
wait
rm -rf ${LockFile}
fi
