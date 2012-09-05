#!/bin/sh

# Setup network configuration parameters
#


# Validate IP address
# from: http://nixcraft.com/shell-scripting/14940-bash-ip-validation.html#post26387
#
is_validip()
{
	case "$*" in
	""|*[!0-9.]*|*[!0-9]) return 1 ;;
	esac

	local IFS=.  ## local is bash-specific
	set -- $*

        [ $# -eq 4 ] &&
	    [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] &&
	    [ ${3:-666} -le 255 ] && [ ${4:-666} -le 254 ]
}

# uci command strings
ucidev='uci set wireless.@wifi-device[0].'
uciif='uci set wireless.@wifi-iface[0].'
uciip='uci set network.lan.'

# write header
echo "Last-Modified: `date`"
echo "Cache-Control: no-cache, must-revalidate"
echo "Pragma: no-cache"
echo "Content-type: text/html"
echo ""


# retrive parameters from query string
# check if the query string is a valid one or undefined (called to fetch settings)
if [ $QUERY_STRING ]; then
	# some parameter passed to the script
	ipaddr="`echo \"$QUERY_STRING\" | cut -d'&' -f1 | cut -d'=' -f2`"
	ssid="`echo \"$QUERY_STRING\" | cut -d'&' -f2 | cut -d'=' -f2`"
	channel="`echo \"$QUERY_STRING\" | cut -d'&' -f3 | cut -d'=' -f2`"
	txpower="`echo \"$QUERY_STRING\" | cut -d'&' -f4 | cut -d'=' -f2`"
	encryption="`echo \"$QUERY_STRING\" | cut -d'&' -f5 | cut -d'=' -f2`"
	key="`echo \"$QUERY_STRING\" | cut -d'&' -f6 | cut -d'=' -f2`"

	# validate data
	if [ $channel -lt 15 ]; then ${ucidev}channel=$channel; fi
	if [ $ssid//[^a-zA-Z0-9\-._]/ ]; then ${uciif}ssid=${ssid//[^a-zA-Z0-9\-._]/}; fi
	if [ $txpower -lt 20 ]; then ${ucidev}txpower=$txpower; fi
	if [ $encryption ]; then ${uciif}encryption="psk2"; else ${uciif}encryption="none"; fi
	if [ $key ]; then ${uciif}key=$key; else ${uciif}key=""; ${uciif}encryption="none"; fi
	uci commit wireless
	wifi

	if is_validip $ipaddr; then
		oldIP=`ifconfig | egrep "addr.*Bcast" | cut -d ':' -f2 | cut -d ' ' -f1`
		if [ "$oldIP" != "$ipaddr" ]; then
			${uciip}ipaddr=$ipaddr
			uci commit network
			ifconfig br-lan $ipaddr
		fi
	fi
fi


echo "<html><header><meta http-equiv='refresh' content='5; url=/c/index.sh'/></header><body>$ssid<br />Network restarting, please wait 5 seconds.</body></html>"

exit 0
