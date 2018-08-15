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
        repositionForm().
    END.

    METHOD PUBLIC CHARACTER repositionForm():
        
    END.

    METHOD PUBLIC CHARACTER recordset():
        cMenuApi:getData(0, TABLE formTable).
        openQuery().
        
        FOR EACH formTable:
            DISPLAY formTable.id.
        END.
        RETURN "".
    END.

    ON RETURN OF formBrowse
     DO:
        IF NOT AVAILABLE formTable THEN RETURN.
        
        cMenuApi:getData(formTable.id, TABLE formTable).
        openQuery().
        RETURN "".
     END.
     
    
END.