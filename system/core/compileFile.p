DEF VAR file      AS CHAR.
DEF VAR fileName  AS CHAR.
DEF VAR rcode     AS CHAR.
DEF VAR absRoot   AS CHAR.

file     = OS-GETENV("fileToCompile").
rcode    = OS-GETENV("tmpCompilePath").
fileName = ENTRY(NUM-ENTRIES(file, '/'), file, '/').
absRoot  = OS-GETENV("absRoot") + "/".
absRoot  = REPLACE(absRoot, "//", "/").
file     = REPLACE(file, "./", absRoot).
file     = REPLACE(file, "//", "/").

IF SEARCH(file) = SEARCH(fileName) OR SEARCH(file) = absRoot + SEARCH(fileName) THEN
    COMPILE VALUE(file) SAVE INTO VALUE(rcode).
ELSE
    MESSAGE "File has duplicate copy in folder: " SEARCH(file) "<>" SEARCH(fileName).

PAUSE 0 BEFORE-HIDE.
QUIT.