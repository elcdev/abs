CLASS systemType:
    
    DEF PUBLIC VAR sysType      AS CHAR    NO-UNDO INIT "".
    {const_systype.i PUBLIC}
    DEF TEMP-TABLE tmpSysC NO-UNDO
        FIELD SYSC  AS CHAR
        FIELD DES   AS CHAR
        FIELD CHVAL AS CHAR
        FIELD inval AS INT64
        FIELD deval AS DEC
        FIELD daval AS DATE
        FIELD loval AS LOG
        FIELD STS   AS INT64
        FIELD stc   AS CHAR
        
        INDEX SYSC SYSC
        .
    
    CONSTRUCTOR systemType():
        GetSysType().
    END.
        
    METHOD PUBLIC CHAR GetSysType():
        IF sysType = "" THEN
         DO:
            sysType = os-getenv("SYS_TYPE").
            IF sysType = ? THEN sysType = "".
            IF sysType <> "" THEN RETURN sysType.
            
            sysType = GetSysTypeByBank().
            IF sysType <> "" THEN RETURN sysType.
            
            IF INDEX(os-getenv("TEMPDIR"), "testbase") > 0 THEN
             DO:
                sysType = SYSTYPE-TEST.
                RETURN sysType.
             END.
         END.
        RETURN sysType.
    END. 
   
    METHOD PUBLIC CHAR GetSysTypeByBank():
        DEF VAR h_Tab AS HANDLE NO-UNDO.
        DEF VAR cDb   AS syspdb NO-UNDO.
        DEF VAR tName AS CHAR   NO-UNDO INIT 'SYS_TYPE'.
        DEF VAR tSys  AS CHAR   NO-UNDO.
        
        IF NOT CONNECTED("BANK") THEN RETURN "".
        
        h_Tab = TEMP-TABLE tmpSysC:HANDLE.
        EMPTY TEMP-TABLE tmpSysC.
        cDb = NEW syspdb().
        
        cdb:DFTH("bank.sysc", "for each bank.sysc no-lock where sysc.sysc='" + tName + "' use-index sysc", 
              TABLE-HANDLE h_Tab BIND).
        
        DELETE OBJECT cDb NO-ERROR.
        
        FIND FIRST TmpSysC WHERE TmpSysC.SysC = tName NO-ERROR.
        IF AVAILABLE TmpSysC THEN tSys = TRIM(TmpSysC.CHVAL).
        ELSE tSys = "".
        RETURN tSys.
    END.
    
    
END CLASS.