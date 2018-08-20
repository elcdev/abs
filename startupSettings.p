/*
    Set startup global settings and parameneters
*/
DEFINE VARIABLE vLine       AS CHARACTER NO-UNDO.
DEFINE VARIABLE projectRoot AS CHARACTER NO-UNDO INIT "C:/Projects/abs/".

CASE OPSYS:
  WHEN "unix" THEN
  DO:
    /* unix envairontment preinitialize */
  END.
  WHEN "win32" THEN 
  DO:
    /* TODO! for windows envairontment development only */
    SESSION:APPL-ALERT-BOXES = FALSE.
    
    IF NOT CONNECTED ("sbsdb") THEN
    DO:
        CONNECT absdb -H 192.168.1.114 -S 10000 NO-ERROR.    
    END.

    projectRoot = REPLACE(projectRoot, "/", CHR(92)).
    
    IF NOT PROPATH MATCHES "*" + projectRoot + "*" THEN
    DO:
        INPUT THROUGH VALUE("CMD.EXE /C DIR " + projectRoot + " /S /A:D /B") NO-ECHO.

        REPEAT:
            IMPORT UNFORMATTED vLine.
            IF vLine MATCHES "*.git*" THEN
            DO:
                NEXT.     
            END.
            PROPATH=PROPATH + ";" + vLine.
        END.

        INPUT CLOSE.
    END.

  END.
END CASE.