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
        WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
        hideForm().
    END.

    METHOD PUBLIC CHARACTER hideForm():
        SUPER:hideHeader().
        HIDE FRAME formFrame. PAUSE 0.
    END.

    METHOD PUBLIC CHARACTER openQuery():
        OPEN QUERY formQuery FOR EACH formTable.
        RUN reposition().
    END.

    METHOD PUBLIC CHARACTER reposition():
        
    END.

    METHOD PUBLIC CHARACTER recordset():
        DEFINE VARIABLE formHandle AS HANDLE.
        
        formHandle = TEMP-TABLE formTable:HANDLE.
        
        cMenuApi:getData(0, TABLE-HANDLE formHandle BIND).
        openQuery().
        
        RETURN "".
    END.

    ON RETURN OF formBrowse
     DO:
        formHandle = TEMP-TABLE formTable:HANDLE.
        
        IF NOT AVAILABLE formTable THEN RETURN.
        
        RETURN cMenuApi:getData(formTable.id, TABLE-HANDLE formHandle BIND).
     END.
     
    
END.