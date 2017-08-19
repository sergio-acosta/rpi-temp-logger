#!/bin/bash

# Constants
# 2100 s = 35 m / 1000000 b = 1 mb
LOG_PATH=/var/log/tempmonitor.log
TIME_PERIOD=2100
MAX_LOG_SIZE=1000000 

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
	exit
else
	main
fi


function getTopCpuProcess(){
	echo $(ps -eo pcpu,args --sort=-%cpu | head -2)
}

function logFile(){
	local cpu="$1"
	local gpu="$2"
    timeAndDate=`date`
    echo "[$timeAndDate] [CPU]  $cpuºC" >> $LOG_PATH
	echo "[$timeAndDate] [GPU]  $gpuºC" >> $LOG_PATH
}

function getCPUprocess(){
	echo $(ps -eo pcpu,args --sort=-%cpu | head -2)
}

function main(){
	
	if [ -e "$LOG_PATH" ]; then
	    read -p "Log file exists. Continue? [y/n]?" -n 1 -r
		echo    # Move to a new line
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 
			fi
	else 
	    touch $LOG_PATH
	fi 
	
	while true
	do 
		cpuTemp=$(cat /sys/class/thermal/thermal_zone0/temp)
		gpuTemp=$(/opt/vc/bin/vcgencmd measure_temp | cut -c6-9)
		
		# CPU temperature formatting
		cpuTempF=$(cut -c1-2 <<< $cpuTemp`.`cut -c3 <<< $cpuTemp)
		# Write info to the log file
		logFile $cpuTempF $gpuTemp
		# Get log file size and delete it if neccesary
		fileSize=`wc -c <"$LOG_PATH"`
		if [ $fileSize -ge $MAX_LOG_SIZE ]; then
			rm $LOG_PATH
			touch $LOG_PATH
		fi
		
		# Wait TIME_PERIOD or exit
		sleep $TIME_PERIOD
	done
}

# TO-DO




