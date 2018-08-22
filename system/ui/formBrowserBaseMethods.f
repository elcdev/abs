/*
	TODO! Move this methods to baseForm.cls when it is posible
*/
	
	DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO INITIAL "".
	DEFINE VARIABLE tmpFormId     AS INT64     NO-UNDO.
	
	DEFINE VARIABLE DEFAULT-REPOSITION-ROW AS INT INIT 7.
	DEFINE VARIABLE FORM-HELP-KEY          AS CHARACTER NO-UNDO INITIAL "HELP".
	DEFINE VARIABLE FORM-TITLE             AS CHARACTER NO-UNDO INITIAL "".

    METHOD PUBLIC RECID SearchById(iId AS INT64):
        DEFINE BUFFER {&formTable} FOR {&formTable}.
        FIND FIRST {&formTable} WHERE {&formTable}.id = iId NO-ERROR.
        IF AVAILABLE {&formTable} THEN RETURN RECID({&formTable}).
        RETURN ?.
    END.
    
	METHOD PUBLIC CHARACTER RepositionBrowse():
        DEFINE VARIABLE tRecid AS RECID NO-UNDO.
        
        tRecid = SearchByKeyword().
        IF OPSYS <> "unix" THEN HIDE MESSAGE. PAUSE 0.
        MESSAGE searchKeyWord. PAUSE 0.
        
        IF tRecid <> ? THEN
         DO:
            formBrowse:SET-REPOSITIONED-ROW(DEFAULT-REPOSITION-ROW, "CONDITIONAL") IN FRAME formFrame.
            REPOSITION formQuery TO RECID (tRecid) NO-ERROR.
            RETURN "".
         END.
        
        RETURN "ERROR-KEYWORD-NOT-FOUND".
    END.
	
    METHOD PUBLIC CHARACTER openQuery():
        OPEN QUERY formQuery FOR EACH {&formTable}.
        RepositionBrowse().
    END.
	
    METHOD PUBLIC CHAR DisableForm():
        DISABLE ALL WITH FRAME formFrame.  PAUSE 0.
        DISABLE ALL WITH FRAME formShadow. PAUSE 0.
        RETURN "".
    END.

    METHOD PUBLIC CHAR HideForm():
		SUPER:hideHeader().
        HIDE FRAME formFrame.  PAUSE 0.
        HIDE FRAME formShadow. PAUSE 0.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR ShowFrame():
		SUPER:showHeader().
        VIEW FRAME formShadow. PAUSE 0.
        VIEW FRAME formFrame.  PAUSE 0.
        ShowData().
        RETURN "".
    END.

	METHOD PUBLIC VOID ShowForm():
        InitForm().
        ShowFrame().
        Recordset().
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4, GO OF FRAME formFrame.
        HideForm().
    END. 
	
    ON ANY-PRINTABLE OF formBrowse
     DO:
        IF LASTKEY >= 32 THEN searchKeyWord = searchKeyWord + CHR(LASTKEY).
        RepositionBrowse().
     END.

	 ON backspace OF formBrowse
     DO:
        searchKeyWord = SUBSTRING(searchKeyWord, 1, LENGTH(searchKeyWord) - 1).
        RepositionBrowse().
     END.
    
    ON UP-ARROW,DOWN-ARROW, PAGE-UP, PAGE-DOWN OF formBrowse
     DO:
        searchKeyWord = "".
        HIDE MESSAGE.
     END.
     
    ON PF2, F2 OF formBrowse
     DO:
        DisableForm().
        RUN formHelp.p(FORM-HELP-KEY).
        ShowForm().
     END.
	 
