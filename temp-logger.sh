#!/bin/bash

# Constants
# Note that 2100 s = 35 m / 1000000 b = 1 mb
readonly LOG_PATH=/var/log/tempmonitor.log
readonly TIME_PERIOD=2100
readonly MAX_LOG_SIZE=1000000 

# Global variables
logCpu=false
runOnce=false

function usage(){
	echo "Usage: $0 [options]"
	echo "	options:"
	echo "		-c Disables internal timer (for running the script once, or in cron)."
	echo "		-p Log also the most CPU-intensive process."
	echo "		-r Displays in the entire log file."
}

function getTopCpuProcess(){
	echo $(ps -eo pcpu,args --sort=-%cpu | head -2)
}

function logFile(){
	local cpu="$1"
	local gpu="$2"
	timeAndDate=$(date)
	echo "[$timeAndDate] [CPU]  $cpuºC" >> $LOG_PATH
	echo "[$timeAndDate] [GPU]  $gpuºC" >> $LOG_PATH
	if [ $logCpu = "true" ]; then
		echo "[$timeAndDate] [Current top process]" >> $LOG_PATH
		echo $(getTopCpuProcess) >> $LOG_PATH
	fi
}


function main(){
	
	# Checks if the log file already exists with 10 sec timeout
	if [ -e "$LOG_PATH" ]; then
		read -t 10 -p "Log file exists. Continue? [Y/n]?" -n 1 -r
		echo    # Move to a new line
			if [[ $REPLY =~ ^[Nn]$ ]]; then
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
		cpuTempF=$(cut -c1-2 <<< $cpuTemp).$(cut -c3 <<< $cpuTemp)
		# Write info to the log file
		logFile $cpuTempF $gpuTemp
		# Get log file size and delete it if neccesary
		fileSize=$(wc -c <"$LOG_PATH")
		if [ $fileSize -ge $MAX_LOG_SIZE ]; then
			rm $LOG_PATH
			touch $LOG_PATH
		fi
		
		# Wait TIME_PERIOD or exit
		if [ $runOnce = "false" ]; then
			sleep $TIME_PERIOD
		else
			exit 0
		fi
	done
}

if [ "$#" -gt 1 ]; then
	echo -e "Illegal number of parameters: $#\nType -h for more help.\n" >&2
	exit 1
fi


while getopts ":hrcp" opt; 
do
	case $opt in
		h)
			usage
			exit 0
			;;
		r)
			cat $LOG_PATH
			exit 0
			;;
		c)
    		runOnce=true
			# main
			;;
		p)
			echo -e "CPU usage log enabled!\n"
			logCpu=true
			# main
			;;
		\?)
      		echo -e "Illegal option: -$OPTARG\nType -h for more help.\n" >&2
			exit 1
      	  	;;
  	esac
done

main




