#!/bin/bash

#Check the presence of intel_pstate driver
#TODO: Support acpi-cpufreq driver also
cpupower frequency-info | grep -i intel_pstate > /dev/null
if [ $? -ne 0 ]
then
    echo "intel_pstate driver not detected"
    exit 1
fi

#Select a random CPU
RANGE=$(nproc)
number=$RANDOM
let "number %= $RANGE"

#C7 should be enough?
for i in 1 2 3 4 5 6 7
do
    cur=$((i-1))
    next=$i
    ls /sys/devices/system/cpu/cpu$number/cpuidle/state$next/name > /dev/null 2>&1 
    if [ $? -ne 0 ]
    then
        break
    fi
done

#Start measuring the percentage of max-c-state for 1 second interval when system is idle.

previous_time_max_cstate=$(cat /sys/devices/system/cpu/cpu$number/cpuidle/state$cur/time)

sleep 1

current_time_max_cstate=$(cat /sys/devices/system/cpu/cpu$number/cpuidle/state$cur/time)

statediff_max_cstate=$((current_time_max_cstate - previous_time_max_cstate))

timediff=1000000

max_cstate_percent=`expr 100 \* $statediff_max_cstate`
max_cstate_percent=$(($max_cstate_percent / timediff))

#Expect the c-state to be >90%
if [ $max_cstate_percent -lt 90 ]
then
    echo "FAIL"
    exit 2
fi



rpm -i --force http://<>/~sujith/stress-0.18.8-1.4.el7.x86_64.rpm  &> /dev/null 2>&1 
no_of_cpus=$(nproc)

stress --cpu $no_of_cpus -t 60 &

sleep 1

#C7 should be enough?
for i in 1 2 3 4 5 6 7
do
    ls /sys/devices/system/cpu/cpu$number/cpuidle/state$i/name > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        previous_time_cstate=$(cat /sys/devices/system/cpu/cpu$number/cpuidle/state$i/time)
        sleep 1
        current_time_cstate=$(cat /sys/devices/system/cpu/cpu$number/cpuidle/state$i/time)
        statediff_cstate=$((current_time_cstate - previous_time_cstate))
        timediff=1000000
        cstate_percent=`expr 100 \* $statediff_cstate`
        cstate_percent=$(($cstate_percent / timediff))
        if [ $cstate_percent -ne 0 ]
        then
          echo "FAIL"
          exit 3
        fi
    else
        break
    fi
done

echo "PASS"
exit 0
