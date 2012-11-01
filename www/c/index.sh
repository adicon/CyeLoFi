#!/usr/bin/haserl
Content-type: text/html

<% # define user functions
_memFree(){
	# get free and total memory
	f="`grep MemFree /proc/meminfo`"
	t="`grep MemTotal /proc/meminfo`"
	# remove part of the string to obtain just numbers
	f="${f% kB}"
	f=${f##* }
	t="${t% kB}"
	t=${t##* }
	# calculate percente
	pf=$(($f*100/$t))
	# output
#	echo -n "$pf%"
	return $pf
}

export HOSTNAME=`uci get system.@system[0].hostname | tr -d '\n'`

%>

<!DOCTYPE html>
<html>
<head>
	<title>CyeLoFi settings</title>

	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Cache-Control" content="no-cache, must-revalidate">
	<meta http-equiv="Pragma" content="no-cache">
	<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" />
	<link rel="apple-touch-icon" href="/CyeLoFi_64.png" />
	<link rel="icon" type="image/png" href="/CyeLoFi_16.png" />
	<meta name="format-detection" content="telephone=no" />
	<link rel="stylesheet" href="/lib/iui/iui.css" type="text/css" />
	<link rel="stylesheet" href="/lib/iui/t/android/android-theme.css" type="text/css"/>
	<script type="application/x-javascript" src="/lib/iui/iui.js"></script>

<style type="text/css">
.sysFont {
	font-family: monospaced;
	font-size: 0.8em;
	color:#6C6;
}
.row>P {
	padding: 0 5px;
}
</style>

<script type="text/javascript">
//<![CDATA[
window.scrollTo(0, 1);
//]]>

function disableMe(id, chk) {
  document.getElementById(id).disabled=!chk.checked;
}

function setSelectByValue( formName, elemName, defVal ) {
  var x=document.getElementById(formName);

  for (var i=0;i<x.length;i++) {
    if (x.elements[i].name == elemName) {
      switch (x.elements[i].type) {
        case 'radio':
          if (x.elements[i].value == defVal) x.elements[i].defaultChecked = true;
        break;
        case 'select-one':
          for (var j=0; j<x.elements[i].length && x.elements[i].children[j].value!=defVal; j++);
          if (j != x.elements[i].length) {
             x.elements[i].children[j].defaultSelected = true;
             x.elements[i].value = defVal;
          }
        break;
      }
    }
  }
}

</script>

</head>

<body>
<div class="toolbar">
  <h1 id="pageTitle"></h1>
  <a id="backButton" class="button" href="#"></a>
</div>
<ul id="home" title="Home" selected="true">
<li><a href="#serial">Serial port setup</a></li>
<li><a href="#network">Network setup</a></li>
<li><a href="#status">Device status</a></li>
<li><a href="#about">About <% echo $HOSTNAME %></a></li>
</ul>

<form id="serial" title="Serial setup" class="panel" name="serial" action="/c/setSerial.sh" method="GET">
  <b>Select comunication parametrers for remote software and COM port.</b><br /><br />
  <fieldset>
    <div class="row">
      <p><label for="ipport">TCP/IP forwarding port:</label>
      <input type="text" id="ipport" name="ipport" value="<% tail -3 /etc/ser2net.conf | tr -s '\n' | cut -d ':' -f1 | tr -d '\n' %>" size=7 maxlength=5 /></p>
      <p><label for="baud">Baud rate:</label>
      <select id="baud" name="baud">
        <option value="9600">9600</option>
        <option value="14400">14400</option>
        <option value="38400">38400</option>
        <option value="115200">115200</option>
      </select></p>
      <p><label for="tty">RS-232 port:</label>
      <% for f in /dev/ttyUSB*; do if [ -c $f ]; then echo "<input type="radio" id="tty" name="tty" value="$f" />`echo $f | cut -d '/' -f3`"; else echo '<i>no serial port found</i>'; fi; done %></p>
    </div>                                                                                                                           
  </fieldset>
  <a class="whiteButton" href="javascript:document.serial.submit()">Apply</a>
  <a class="whiteButton" href="javascript:document.serial.reset();">Reset</a>
</form>

<form id="network" title="Network setup" class="panel" name="network" action="/c/setNetwork.sh" method="GET">
  <b>TCP/IP Network</b><br />
  <span style="font-size:0.8em; font-style:italic;">Please pay attention! If you change this IP address you will loose your connection to this page and to reload it you will have to change IP in the address bar accordingly.</span>
  <fieldset>
    <div class="row">
      <p><label for="ipaddr">Device IP address:</label>
      <input type="text" id="ipaddr" name="ipaddr" value="<% uci get network.lan.ipaddr %>" size=15 maxlength=15 />
    </div>
  </fieldset>
  <b>Wireless network</b><br />
  <fieldset>
    <div class="row">
      <p><label for="ssid">WiFi SSID name:</label>
      <input type="text" id="ssid" name="ssid" value="<% uci get wireless.@wifi-iface[0].ssid %>" size=15 maxlength=15 /></p>
      <p><label for="channel">WiFi channel:</label>
      <select id="channel" name="channel">
        <% for i in $(seq 1 11); do echo "<option value='$i'>$i</option>\n"; done %>
      </select></p>
      <p><label for="txpower">Tx power:</label>                                                                                  
      <select id="txpower" name="txpower">                                                                                           
        <option value='1'>Low</option>
        <option value='10'>Med</option>
        <option value='18'>Max</option>                                                 
      </select></p>
      <p><label for="wep_enb">Security (WPA2-PSK) enabled </label>
      <input type="checkbox" name="wep_enb" value="wep_enb" <% if [ "`uci -q get wireless.@wifi-iface[0].encryption`" != "none" ]; then echo "checked"; fi %> onchange="disableMe('wep_pwd', this)" /><br />
      <label for="wep_pwd"> &nbsp; Secret password</label>
      <input type="text" id="wep_pwd" name="wep_pwd" value="<% pw=`uci -q get wireless.@wifi-iface[0].key`; if [ $pw ]; then echo $pw; else echo 'no password'; fi %>" size=15 maxlength=40 <% if [ "`uci -q get wireless.@wifi-iface[0].encryption`" == "none" ]; then echo "disabled"; fi %> /></p>
    </div>
  </fieldset>
  <a class="whiteButton" href="javascript:document.network.submit()">Apply</a>
  <a class="whiteButton" href="javascript:document.network.reset()">Reset</a>
</form>

<div id="status" title="Device status">
  Device version: <span class="sysFont">
  <% grep CyeLoFi /etc/issue; echo -n " on "; cat /var/sysinfo/model %>
  </span><br />
  OS version: <span class="sysFont">
  <% uname -a %>
  </span><br />
  OpenWrt version: <span class="sysFont">
  <% grep DISTRIB_ID /etc/openwrt_release | cut -d '"' -f2 | tr -d '"' %>
  <% grep DISTRIB_RELEASE /etc/openwrt_release | cut -d '"' -f2 | tr -d '"' %>
  <% grep DISTRIB_REVISION /etc/openwrt_release | cut -d '"' -f2 | tr -d '"' %>
  </span><br />
  System uptime: <span class="sysFont">
  <% uptime %>
  </span><br />
  Free memory: <span class="sysFont">
  RAM <% echo $((`grep MemFree /proc/meminfo | awk '{ print $2 }'`*100/`grep MemTotal /proc/meminfo | awk '{ print $2 }'`))% %>
  - disk <% echo $((100-`df | grep rootfs | awk '{ print $5 }' | tr -d '%'`))% %>
  </span><br />
  Ser2Net configuration: <span class="sysFont">
  <% tail -3 /etc/ser2net.conf | tr -s '\n' %>
  </span><br />
  USB connected device(s):<span class="sysFont">
  <% dmesg | grep "ttyUSB" | cut -d ']' -f2 %>
  </span><br />
  WiFi SSID and MAC: <span class="sysFont">
  <% uci get wireless.@wifi-iface[0].ssid %> &nbsp; @ &nbsp;
  <% ifconfig wlan0 | grep HWaddr | cut -d ' ' -f10 %>
  </span><br />
  Device IP address: <span class="sysFont">
  <% ifconfig | egrep "addr.*Bcast" | cut -d ':' -f2 | cut -d ' ' -f1 %>
  </span><br />
</div>

<div id="about" title="About <% echo $HOSTNAME %>">
<div style="text-align: center;">
<img src="/CyeLoFi_128.png" alt="logo" width="128" height="128"><br />
<p><span style="font-size:1.5em; color:#0275E8;"><% echo $HOSTNAME %></span><br 
<i style="font-size:1.2em; color:#5EAAF7;">Liberate your telescope</i><br />    
<span style="font-size:0.9em;">Copyright 2012 Andrea Di Dato</span></p> 
</div>
<br />
Contacts:<br />
 &nbsp; <a href="mailto:adicon74@gmail.com">e-mail</a><br />
 &nbsp; <a href="http://adicon.lahost.org/" target="_blank">web site</a><br />
 &nbsp; <a href="http://adicon.lahost.org/<% echo $HOSTNAME %>/" target="_blank"><% echo $HOSTNAME %> project page</a><br />
<br />
<span style="font-size:0.8em;">
Credits:<br />
 &nbsp; Software released under GNU <a href="http://www.gnu.org/licenses/gpl.html">GPLv3</a> license<br />
 &nbsp; Web interface powered by <a href="http://www.iui-js.org/" target="_blank">iUI web framework</a><br />
 &nbsp; Linux free operative system by <a href="http://openwrt.org/">OpenWRT</a><br />
</span>
</div>

<script type="text/javascript">
  setSelectByValue('serial', 'tty', '<% tail -3 /etc/ser2net.conf | tr -s '\n' | cut -d ':' -f4 | tr -d '\n' %>');
  setSelectByValue('serial', 'baud', '<% tail -3 /etc/ser2net.conf | tr -s '\n' | cut -d ':' -f5 | cut -d ',' -f1 | tr -d '\n' %>');
  setSelectByValue('network', 'channel', '<% uci get wireless.@wifi-device[0].channel | tr -d '\n' %>');
  setSelectByValue('network', 'txpower', '<% uci get wireless.@wifi-device[0].txpower | tr -d '\n' %>');
</script>

</body>
</html>

