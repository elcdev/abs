CLASS formBrowserBaseType IMPLEMENTS formBrowserInterface:
    DEFINE VARIABLE FORM_HELP_KEY AS CHARACTER NO-UNDO INITIAL "HELP".
    DEFINE VARIABLE FORM_TITLE    AS CHARACTER NO-UNDO INITIAL "".
    DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO INITIAL "".
    DEFINE VARIABLE tmpFormId     AS INT64     NO-UNDO INITIAL 0.
    
    /*DEFINE BUFFER searchBuffer FOR formTable.*/
    DEFINE VARIABLE garbage       AS garbageCollectorType.
    
    CONSTRUCTOR formBrowserBaseType():
        
    END.
     
    DESTRUCTOR formBrowserBaseType():

    END.
     
    METHOD PUBLIC CHARACTER InitForm():
    END.
    
    METHOD PUBLIC CHARACTER Recodset():
    END.
    
    METHOD PUBLIC INT64 SearchByKeyword(searchKeyword AS CHARACTER, searchBuffer AS BUFFER):
    END.
    
    METHOD PUBLIC CHAR RepositionBrowse():
        IF searchKeyWord <> "" THEN
         DO:
            searchByKeyWord(searchKeyWord).
            IF NOT AVAILABLE searchBuffer THEN
             DO:
                searchKeyWord = SUBSTRING(searchKeyWord, 1, LENGTH(searchKeyWord) - 1).
                RETURN RepositionBrowse().
             END.
            PAUSE 0 BEFORE-HIDE.
            MESSAGE searchKeyWord.
         END.
        ELSE
         DO:
            HIDE MESSAGE.
            FIND FIRST searchBuffer WHERE searchBuffer.id = tmpFormId
                USE-INDEX id NO-LOCK NO-ERROR.
         END.
        
        IF NOT AVAILABLE searchBuffer THEN
         DO:
            formBrowse:SET-REPOSITIONED-ROW(7, "CONDITIONAL") IN FRAME formFrame.
            REPOSITION formQuery TO RECID RECID(searchBuffer) NO-ERROR.
         END.
        
        IF AVAILABLE searchBuffer THEN RETURN INT64(searchBuffer.id).
        
        RETURN "ERROR-KEYWORD-NOT-FOUND".
    END.
    
    METHOD PUBLIC INT64 DisableForm():
        DISABLE ALL WITH FRAME formFrame.  PAUSE 0.
        DISABLE ALL WITH FRAME formShadow. PAUSE 0.
    END.

    METHOD PUBLIC INT64 HideForm():
        HIDE FRAME formFrame.  PAUSE 0.
        HIDE FRAME formShadow. PAUSE 0.
    END.
    
    METHOD PUBLIC INT64 ShowFrame():
        VIEW FRAME formShadow. PAUSE 0.
        VIEW FRAME formFrame.  PAUSE 0.
        ShowData().
    END.

    METHOD PUBLIC INT64 ShowForm():
        InitForm().
        ShowFrame().
        Recordset().
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4, GO OF FRAME formFrame.
        HideForm().
    END.    
    
    ON PF2, F2 OF formBrowse
     DO:
        DisableForm().
        RUN show_form_help.p(FORM_HELP_KEY).
        ShowForm().
     END.
     
    ON ANY-PRINTABLE OF formBrowse
     DO:
        IF LASTKEY >= 32 THEN searchKeyWord = searchKeyWord + CHR(LASTKEY).
        RepositionBrowse().
     END.
    
    ON UP-ARROW,DOWN-ARROW, PAGE-UP, PAGE-DOWN OF formBrowse
     DO:
        searchKeyWord = "".
        HIDE MESSAGE.
     END.
    
    METHOD PUBLIC CHARACTER RecordsetOpen ():
        OPEN QUERY formQuery FOR EACH formTable.
        RETURN RepositionBrowse().
    END.
    

END CLASS.