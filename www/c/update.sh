#!/usr/bin/haserl --upload-limit=4096 --upload-dir=/tmp 
content-type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
<link rel="icon" type="image/png" href="/CyeLoFi_16.png" />
<title>CyeLoFi update procedure</title>

<style type="text/css">
BODY {
  color: #DDD;
  background-color: #000;
}
A {
  color: #FFF;
}
</style>

<%
if test -n "$HASERL_uploadfile_path"; then
%>
   <script type="text/javascript">
   seconds = 49;
   function countdown() {
       seconds--;
       if (seconds != -1) {
           setTimeout('countdown()', 1000)
           document.getElementById("countdown").innerHTML= seconds;
       } else {
           document.location="/c/index.sh";
       }
   }
   </script>
   
   </head>

   <body onload="countdown()">
   <h2><img src="/CyeLoFi_64.png" width="64" height="64" alt="logo"><br />CyeLoFi - update procedure</h2>

<% 
   echo "<p>Processing file $FORM_uploadfile_name</p>"
   ext=`echo -n $FORM_uploadfile_name | awk -F . '{ print $NF }'`
   if [ "$ext" == "cfi" ]; then
      # correct file type
      mkdir /tmp/upd
      echo "<p>Extracting files..."
      tar -C /tmp/upd -xzf $HASERL_uploadfile_path
      # Deleting uploaded file
      rm -f $HASERL_uploadfile_path
      if test -f "/tmp/upd/setup.sh"; then
         echo "<br />Updating..."
         cd /tmp/upd/
         /bin/sh /tmp/upd/setup.sh
         # Deleting temp dir
         rm -fR /tmp/upd/
         echo "<br />Done!<br /><br /><span style='color:#66CC66;'><b>Rebooting... </b>Please wait <span id='countdown'>50</span> seconds.</span>"
         reboot
      else
         echo "<br /><br /><b>Error in package, setup file not found.</b>"
         # Deleting temp dir
         rm -fR /tmp/upd/
      fi
   else
      echo "<p><b>The file is of an incorrect type.</b></p>"
      rm -f $HASERL_uploadfile_path
   fi
else %>
   </head>

   <body>
   <h2><img src="/CyeLoFi_64.png" width="64" height="64" alt="logo"><br />CyeLoFi - update procedure</h2>

   <p style="font-size:1.2em;">Please, select the file to upload to the system.</p>

   <form action="<% echo -n $SCRIPT_NAME %>" method=POST enctype="multipart/form-data" >
   <input type="file" name="uploadfile">
   <input type="submit" value="Upload">
   </form>
<% fi %>


</body>
</html>

