#!/bin/sh

if [ $(whoami) != "root" ]
then
	echo "You must run this script as superuser!"
	exit 1
fi

# paramter check
if [ $# -lt 2 ]
then
	echo "Usage: `basename $0` path <maximum used disc space> filesize_in_MB sleeptime"
	exit 1
fi

path=$1
maxusedspace=$2

# allocate default values if no param is given
if [ -z $3 ];
then
	filesize=$((1024 * 1024 * 1024)) # 1GB
else
	filesize=$(($3 * 1024 * 1024))
fi

if [ -z $4 ];
then
      sleeptime=5
else
      sleeptime=$4
fi

# create $path if does not exist yet. This is the place, in which the files are created
if [ ! -d $path ]
then
	mkdir $path
fi

logfile=$path/fill_disk.log

while true; do
	usedspace=`df -h $path | awk '{print $5}'| tail -1 | tr -d '%'`
	if [ $usedspace -gt $maxusedspace ]; 
	then
		echo "free space: $usedspace (bigger than max $maxusedspace) --> no op"
	else
		newlogfilename=$logfile.$(date +'%Y%m%d_%H%M%S')
		echo "used space: $usedspace (max is $maxusedspace) ### generating new tmp file $newlogfilename of size $filesize"
		dd if=/dev/zero of=$newlogfilename bs=$filesize count=1 status=none
	fi
	sleep $sleeptime
done
