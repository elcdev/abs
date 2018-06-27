DEF INPUT PARAMETER iStr AS LONGCHAR.

iStr = iStr + CHR(10).
COPY-LOB iStr TO FILE "/home/abs.web/www/tmp/debug.log" APPEND.