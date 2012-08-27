#!/usr/bin/haserl
content-type: text/plain

<%

if [[ -n "$QUERY_STRING" ]]; then
   echo "Requested file: " $QUERY_STRING
   echo ""
   if [[ -f $QUERY_STRING ]]; then  
      cat $QUERY_STRING
   else
      echo "File does not exist."
   fi
else
   echo "No file specified."
fi

%>

