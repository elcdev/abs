#!/bin/bash
#compiles file and outputs result to stdout

cd /home/abs/bin

OUT=`tempfile`

if [ "$REQUEST_METHOD" = "POST" ]; then
    read -n $CONTENT_LENGTH POSTDATA <&0
    export POSTDATA
fi


../bin/absEditor index.p -b>$OUT 2>$OUT.err

head -n 1 $OUT|grep -i "content-type\|Location:"
#>$OUT.ttt
errorCode=$?
errorSize=$(stat -c%s "$OUT.err")
echo $errorCode>$OUT.tty

if [ $errorCode -gt 0 ] || [ $errorSize -gt 2 ]
then
    echo "content-type: text/html;"
    echo 
    echo "<pre>"
    echo "<h3>Error in Openedge files. Look at logs for errors...</h3>"
    tail -f 20 $absLogFile
    echo '<b>Output:</b> <i style="color:blue">'
    cat $OUT
    echo "</i>"
    echo "<b>Error output:</b>"
    cat $OUT.err
else
    cat $OUT
fi


rm $OUT
rm $OUT.err
