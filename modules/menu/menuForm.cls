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
    DEFINE VARIABLE parentId      AS INT64     NO-UNDO INITIAL 0.
    
    DEFINE QUERY formQuery FOR formTable.

    DEFINE BROWSE formBrowse QUERY formQuery DISPLAY
        formTable.position      FORMAT ">9"    LABEL "LN"
        formTable.description   FORMAT "X(58)" LABEL "DESCRIPTION"
        formTable.function_name FORMAT "X(14)" LABEL "FUNCTION"
        "> "                    FORMAT "XX"    LABEL "SB"
        WITH 18 DOWN NO-BOX NO-LABELS NO-SCROLLBAR-VERTICAL
        SIZE 78 BY 20 
        .
        
    DEFINE FRAME formFrame
        formBrowse HELP " "
      WITH NO-LABELS NO-BOX SIZE 80 BY 20 OVERLAY ROW 3.

    DEFINE FRAME formShadow
      WITH NO-LABELS NO-BOX SIZE 80 BY 20 OVERLAY ROW 3.

    {formBrowserBaseMethods.f}
    
    CONSTRUCTOR menuForm():
        cMenuApi = NEW menuApi().
    END.
    
    CONSTRUCTOR menuForm(iParentId AS INT64):
        cMenuApi = NEW menuApi().
        parentId = iParentId.
    END.
    
    DESTRUCTOR menuForm():
        DELETE OBJECT cMenuApi NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER InitForm():
        RETURN "".
    END.
    
    METHOD PUBLIC VOID ShowData():
        ENABLE formBrowse WITH FRAME formFrame. 
        PAUSE 0.
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

    METHOD PUBLIC CHARACTER recordset():
        cMenuApi:getData(parentId, INPUT-OUTPUT TABLE formTable).
        openQuery().
        RETURN "".
    END.
    
    ON RETURN OF formBrowse
     DO:
        IF NOT AVAILABLE formTable THEN RETURN.
        
        cMenuApi:getData(formTable.id, INPUT-OUTPUT TABLE formTable).
        openQuery().
        
        RETURN "".
     END.
     
    
END.
