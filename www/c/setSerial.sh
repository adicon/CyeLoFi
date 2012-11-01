#!/bin/sh

# Setup configuration file for ser2net command in /etc/ser2net.cfg
# example file:
#   4030:raw:0:/dev/ttyUSB0:9600,8DATABITS,NONE,1STOPBIT,LOCAL


# settings ini file
inifile='/etc/ser2net.conf'

# write header
echo "Last-Modified: `date`"
echo "Cache-Control: no-cache, must-revalidate"
echo "Pragma: no-cache"
echo "Content-type: text/html"
echo ""


# write parameter to INI file
# check if the query string is a valid one or undefined (called to fetch settings)
if [ $QUERY_STRING ]; then
	# some parameter passed to the script
	port="`echo $QUERY_STRING | cut -d'&' -f1 | cut -d'=' -f2`"
	baud="`echo $QUERY_STRING | cut -d'&' -f2 | cut -d'=' -f2`"
	com="`echo $QUERY_STRING | cut -d'&' -f3 | cut -d'=' -f2 | sed 's/%2F/\//g'`"

	# validate TTY device
	if [ -c $com ]; then
		echo -e "\n\n$port:raw:0:$com:$baud,NONE,1STOPBIT,8DATABITS,-XONXOFF,-RTSCTS,LOCAL\n\n" > $inifile
		pidser=`ps | grep ser2net | grep -v grep | cut -d' ' -f2`
		kill -HUP $pidser
	fi
fi


echo "<html><header><meta http-equiv='refresh' content='1; url=/c/index.sh'/></header></html>"

exit 0