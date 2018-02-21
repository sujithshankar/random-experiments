#!/bin/bash
#
#How to run: ./cpu.sh <time in seconds>
#

function quit {
if [ $? -eq 0 ]
then
    echo "Error/crash detected"
    exit 1
fi
}

function check_error_crash {
dmesg | grep -i error
quit

dmesg | grep -i trace
quit

dmesg | grep -i taint
quit
}

#1. Clear the dmesg
dmesg -C

#2. Install the stress tool.
rpm -i --force http://<>/~sujith/stress-0.18.8-1.4.el7.x86_64.rpm 

#3. Run the stress for one hour
no_of_cpus=$(nproc)

stress --cpu $no_of_cpus -t $1
check_error_crash

stress --io $no_of_cpus -t $1
check_error_crash

stress --vm $no_of_cpus -t $1
check_error_crash

stress -d $no_of_cpus -t $1
check_error_crash
