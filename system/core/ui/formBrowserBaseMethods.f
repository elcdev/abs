/*
	TODO! Move this methods to baseForm.cls when it is posible
*/

	DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO INITIAL "".
	DEFINE VARIABLE tmpFormId     AS INT64     NO-UNDO.
	
	DEFINE VARIABLE DEFAULT-REPOSITION-ROW AS INT INIT 7.
		
    METHOD PUBLIC RECID SearchById(iId AS INT64):
        DEFINE BUFFER formTable FOR formTable.
        FIND FIRST formTable WHERE formTable.id = iId NO-ERROR.
        IF AVAILABLE formTable THEN RETURN RECID(formTable).
        RETURN ?.
    END.
    
	METHOD PUBLIC CHARACTER RepositionBrowse():
        DEFINE VARIABLE tRecid AS RECID NO-UNDO.
        
        tRecid = SearchByKeyword().
        HIDE MESSAGE. PAUSE 0.
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
        OPEN QUERY formQuery FOR EACH formTable.
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

	METHOD PUBLIC CHAR ShowForm():
        InitForm().
        ShowFrame().
        Recordset().
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4, GO OF FRAME formFrame.
        RETURN HideForm().
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
     
	
/*
    DEFINE VARIABLE FORM_HELP_KEY AS CHARACTER NO-UNDO INITIAL "HELP".
    DEFINE VARIABLE FORM_TITLE    AS CHARACTER NO-UNDO INITIAL "".
    

    DEFINE PUBLIC VARIABLE tmpFormId     AS INT64     NO-UNDO INITIAL 0.

    METHOD PUBLIC CHARACTER InitForm():
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER Recodset():
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
     
    
    METHOD PUBLIC CHARACTER RecordsetOpen ():
        OPEN QUERY formQuery FOR EACH formTable.
        RETURN RepositionBrowse().
    END.
    */