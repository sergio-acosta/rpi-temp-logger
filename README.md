
# rpi-temp-logger
This scripts reads temperature from two of the Raspberry Pi temperature sensors and writes this information to a -custom- log file. The idea is to run it in the background to analyze the performance of a cooling method, or to check the scope of an overclooking setup.

# Installation
## Monitor in the background with internal timer
First download the script, make it executable and then run it in the background using `nohup` 
```shell
git clone https://github.com/sergio-acosta/rpi-temp-logger
cd rpi-temp-logger
chmod +x temp-logger.sh
nohup ./temp-logger.sh
```

## Monitor in the background periodically with `cron`
Again, download the script and copy to an appropiate folder. Make it executable and add it to `crontab` using the flag `-c`
```shell
git clone https://github.com/sergio-acosta/rpi-temp-logger
sudo cp -r rpi-temp-logger /opt
cd /opt/rpi-temp-logger
chmod +x temp-logger.sh
sudo su
crontab -e
```
Then you should add a line like this (example, to save a log every min). Remember to add -c to disable internal timer.

```shell
* * * * * /opt/rpi-temp-logger/temp-logger.sh -c
```


## Customization
There are three constants declared in the shell script:
`LOG_PATH`: the place where you want to store the log file.
`TIME_PERIOD`: the time in seconds you want to do the temperature check. (is disabled when using `-c` flag)
`MAX_LOG_SIZE`: max log size in bytes. When reached, the script will delete previous log file and start a new one.

## Usage to monitor for a short period of time
To read the information of the logger you can show the entire file on screen
```
cat /var/log/tempmonitor.log
```
or you can use `tail` to read the last 15 lines:
```
tail -n15 /var/log/tempmonitor.log
```
# Flags
Flags are currently in development.

| Flag | Purpose                                               |
|------|-------------------------------------------------------|
| -c   | Disables internal timer (for long-term crontab usage) |
| -p   | Adds to the log file the most CPU consumming process. |
| -r   | Shows content of the log file (if exists)             |
