#!/bin/bash

ps_file="/tmp/psax.log"
echo "PID TTY  STAT   TIME COMMAND" > $ps_file
pid_list=$(ls /proc/ | grep -E '^[0-9]+' | sort -n)
clk_tck_cpu=$(getconf CLK_TCK)
for i in ${pid_list[@]}
do
    stat=$(cat /proc/$i/stat 2>/dev/null);
    cmd=$(cat /proc/$i/status 2>/dev/null | grep Name | awk {'print $2'});
    cmd_f=$(cat /proc/$i/cmdline 2>/dev/null);
    state=$(cat /proc/$i/status 2>/dev/null | grep State | awk {'print $2'});

    pid=$(echo $stat | awk '{print $1}' 2>/dev/null);
    tty=$(echo $stat | awk '{print $7}' 2>/dev/null);
    utime=$(echo $stat | awk '{print $13}' 2>/dev/null);
    stime=$(echo $stat | awk '{print $14}' 2>/dev/null);

    pid_time=0
    pid_time=$(echo $utime / $clk_tck_cpu + $stime / $clk_tck_cpu | bc 2>/dev/null);
    tty_of_proc=$(echo $stat | awk '{print $7}' 2>/dev/null);
    tty_of_proc_binary=$(echo "obase=2;$tty_of_proc" | bc 2>/dev/null)

    tty_min_bin=$(echo $tty_of_proc_binary | grep -o '[0-1]\{8\}$')
    tty_maj_bin=$(echo $tty_of_proc_binary | sed "s/[0-1]\{8\}$//g")
    tty_min_dec=$((2#$tty_min_bin))
    tty_maj_dec=$((2#$tty_maj_bin))
    for file in $(find /sys/dev/ -name $tty_maj_dec:$tty_min_dec)
        do
            source ${file}/uevent;
            result_tty=$DEVNAME
        done;
    if [[ -z $result_tty ]]; then
        result_tty='?'
    fi
    echo "$i $result_tty $state  $pid_time  [$cmd $cmd_f]"? >> $ps_file;
done

cat $ps_file