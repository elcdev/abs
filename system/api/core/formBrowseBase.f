    DEFINE VARIABLE FORM_HELP_KEY AS CHARACTER NO-UNDO INITIAL "HELP".
    DEFINE VARIABLE FORM_TITLE    AS CHARACTER NO-UNDO INITIAL "".
    DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO INITIAL "".

    DEFINE PUBLIC VARIABLE tmpFormId     AS INT64     NO-UNDO INITIAL 0.
    DEFINE PUBLIC VARIABLE garbage       AS garbageCollectorType.
    
    CONSTRUCTOR formBrowserBaseType():
        garbage = NEW garbageCollectorType().
    END.
     
    DESTRUCTOR formBrowserBaseType():
		DELETE OBJECT garbage NO-ERROR.
    END.
     
    METHOD PUBLIC CHARACTER InitForm():
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER Recodset():
        RETURN "".
    END.
    
	/*
    METHOD PUBLIC RECID SearchByKeyword(searchKeyword AS CHARACTER):
        IF searchKeyWord = "" OR searchKeyWord = ? THEN RETURN ?.
        RETURN ?.
    END.
    
    METHOD PUBLIC RECID SearchById(iId AS INT64):
        RETURN ?.
    END.
    */
	
    METHOD PUBLIC CHARACTER RepositionBrowse():
        DEFINE VARIABLE tRecid AS RECID NO-UNDO.
        
        IF searchKeyWord <> "" THEN
         DO:
            IF tRecid = ? THEN
             DO:
                searchKeyWord = SUBSTRING(searchKeyWord, 1, LENGTH(searchKeyWord) - 1).
                RETURN RepositionBrowse().
             END.
            PAUSE 0 BEFORE-HIDE.
            MESSAGE searchKeyWord.
         END.
        ELSE
         DO:
            tRecid = SearchById(tmpFormId).
            HIDE MESSAGE.
            /*
            FIND FIRST searchBuffer WHERE searchBuffer.id = tmpFormId
                USE-INDEX id NO-LOCK NO-ERROR.
                */
         END.
        
        IF tRecid <> ? THEN
         DO:
            formBrowse:SET-REPOSITIONED-ROW(7, "CONDITIONAL") IN FRAME formFrame.
            REPOSITION formQuery TO RECID RECID(tRecid) NO-ERROR.
            RETURN "".
         END.
        
        RETURN "ERROR-KEYWORD-NOT-FOUND".
    END.
    
    METHOD PUBLIC CHAR DisableForm():
        DISABLE ALL WITH FRAME formFrame.  PAUSE 0.
        DISABLE ALL WITH FRAME formShadow. PAUSE 0.
        RETURN "".
    END.

    METHOD PUBLIC CHAR HideForm():
        HIDE FRAME formFrame.  PAUSE 0.
        HIDE FRAME formShadow. PAUSE 0.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR ShowFrame():
        VIEW FRAME formShadow. PAUSE 0.
        VIEW FRAME formFrame.  PAUSE 0.
        ShowData().
        RETURN "".
    END.

    METHOD PUBLIC CHAR ShowForm():
        InitForm().
        ShowFrame().
        Recordset().
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4, GO OF FRAME formFrame.
        RETURN HideForm().
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
    