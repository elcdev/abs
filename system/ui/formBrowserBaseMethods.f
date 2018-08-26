/*
	TODO! Move this methods to baseForm.cls when it is posible
*/

	
	DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO INITIAL "".
	DEFINE VARIABLE tmpFormId     AS INT64     NO-UNDO.
	
	DEFINE VARIABLE DEFAULT-REPOSITION-ROW AS INT INIT 7.
	DEFINE VARIABLE FORM-HELP-KEY          AS CHARACTER NO-UNDO INITIAL "HELP".
	DEFINE VARIABLE FORM-TITLE             AS CHARACTER NO-UNDO INITIAL "".
	DEFINE VARIABLE ENABLE-SHADOW          AS LOG       NO-UNDO INITIAL TRUE.
	
    DEFINE FRAME formShadow
      WITH NO-LABELS NO-BOX SIZE 45 BY 15 OVERLAY ROW 5 DCOLOR 1.
	  
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
		IF ENABLE-SHADOW THEN
			DISABLE ALL WITH FRAME formShadow. PAUSE 0.
        RETURN "".
    END.

    METHOD PUBLIC CHAR HideForm():
		SUPER:hideHeader().
        HIDE FRAME formFrame.  PAUSE 0.
		IF ENABLE-SHADOW THEN
			HIDE FRAME formShadow. PAUSE 0.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR ShowFrame():
		SUPER:showHeader().
        IF ENABLE-SHADOW THEN 
			VIEW FRAME formShadow.
        VIEW FRAME formFrame.  PAUSE 0.
        ShowData().
        RETURN "".
    END.

	METHOD PUBLIC VOID ShowForm():
        InitForm().
		InitShadowForm().
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
	
	ON PF4, F4 OF formBrowse
	 DO:
		DisableForm().
		HideForm().
	 END.

	METHOD PUBLIC CHARACTER InitShadowForm():
        IF NOT ENABLE-SHADOW THEN RETURN "NO-SHADOW".
        
        FRAME formShadow:WIDTH    = FRAME formFrame:WIDTH.
        FRAME formShadow:Height   = FRAME formFrame:height.
        FRAME formShadow:COL      = FRAME formFrame:COLUMN + 2.
        FRAME formShadow:ROW      = FRAME formFrame:ROW  + 1.
		
        RETURN "".
    END.