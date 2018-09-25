USING modules.*.
USING system.core.*.
USING system.ui.*.
USING system.api.core.*.
USING system.api.systemSetins.*.

/*
    Set startup global settings and parameneters
*/
DEFINE VARIABLE vLine       AS CHARACTER NO-UNDO.
DEFINE VARIABLE projectRoot AS CHARACTER NO-UNDO INIT "C:/Projects/abs/".

session:date-format = "dmy".

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
        CONNECT absdb -H absdb.com -S 10000 NO-ERROR.    
    END.

    projectRoot = REPLACE(projectRoot, "/", CHR(92)).
    
    IF NOT PROPATH MATCHES "*" + projectRoot + "*" THEN
    DO:
        INPUT THROUGH VALUE("CMD.EXE /C DIR " + projectRoot + " /S /A:D /B") NO-ECHO.

        REPEAT:
            IMPORT UNFORMATTED vLine.
            IF vLine MATCHES "*.git*" OR vLine MATCHES "*/tmp/*" OR vLine MATCHES "*/www/public/*" THEN
             DO:
                NEXT.     
             END.
            IF NOT PROPATH MATCHES "*;" + vLine + "*" THEN
             DO:
                PROPATH=PROPATH + ";" + vLine.
             END.
        END.

        INPUT CLOSE.
    END.

  END.
END CASE.