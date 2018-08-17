/*
********************************************************************************
********************************************************************************
12.07.2018 22:48   ABS SYSTEM                                       Alan Meister
--------------------------------------------------------------------------------
POS FUNCTION DESCRIPTION                                                 SUBMENU
================================================================================
1   CLIENTS  Clients main menu                                                 >
================================================================================
Find menu         [************************************************************]
*/

CLASS menuForm INHERITS headerForm:
    DEFINE VARIABLE cMenuApi AS menuApi NO-UNDO.
    {menuTable.i}
    DEFINE VARIABLE tmpFormId     AS INT64     NO-UNDO.
    DEFINE VARIABLE searchKeyWord AS CHARACTER NO-UNDO.
    
    DEFINE QUERY formQuery FOR formTable.

    DEFINE BROWSE formBrowse QUERY formQuery DISPLAY
        formTable.position      FORMAT ">9"    LABEL "LN"
        formTable.description   FORMAT "X(30)" LABEL "DESCRIPTION"
        formTable.function_name FORMAT "X(14)" LABEL "FUNCTION"
        WITH 18 DOWN NO-BOX NO-LABELS
        .
        
    DEFINE FRAME formFrame
        formBrowse HELP " "
      WITH NO-LABELS NO-BOX.
      
    CONSTRUCTOR menuForm():
        cMenuApi = NEW menuApi().
    END.

    DESTRUCTOR menuForm():
        DELETE OBJECT cMenuApi NO-ERROR.
    END.

    METHOD PUBLIC VOID showForm():
        SUPER:showHeader().
        VIEW FRAME formFrame.   PAUSE 0.
        ENABLE formBrowse WITH FRAME formFrame.
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
        hideForm().
    END.

    METHOD PUBLIC CHARACTER hideForm():
        SUPER:hideHeader().
        HIDE FRAME formFrame. PAUSE 0.
    END.

    METHOD PUBLIC CHARACTER openQuery():
        OPEN QUERY formQuery FOR EACH formTable.
        RepositionBrowse().
    END.

    METHOD PUBLIC RECID SearchByKeyword():
        IF searchKeyWord = "" OR searchKeyWord = ? THEN RETURN SearchById(tmpFormId).

        FIND FIRST formTable WHERE formTable.function_name MATCHES '*' + searchKeyWord + '*' NO-ERROR.
        IF AVAILABLE formTable THEN RETURN RECID(formTable).

        FIND FIRST formTable WHERE formTable.description MATCHES "*" + searchKeyWord + "*" NO-ERROR.
        IF AVAILABLE formTable THEN RETURN RECID(formTable).
        
        searchKeyWord = SUBSTRING(searchKeyWord, 1, LENGTH(searchKeyWord) - 1).
        
        RETURN SearchByKeyword().
    END.
    
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
            formBrowse:SET-REPOSITIONED-ROW(7, "CONDITIONAL") IN FRAME formFrame.
            REPOSITION formQuery TO RECID (tRecid) NO-ERROR.
            RETURN "".
         END.
        
        RETURN "ERROR-KEYWORD-NOT-FOUND".
    END.
    
    METHOD PUBLIC CHARACTER recordset():
        cMenuApi:getData(0, INPUT-OUTPUT TABLE formTable).
        openQuery().
        RETURN "".
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
     
    ON RETURN OF formBrowse
     DO:
        IF NOT AVAILABLE formTable THEN RETURN.
        
        cMenuApi:getData(formTable.id, INPUT-OUTPUT TABLE formTable).
        openQuery().
        
        RETURN "".
     END.
     
    
END.
