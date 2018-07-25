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

    DEFINE QUERY menuQuery FOR menuTable.

    DEFINE BROWSE menuBrowse QUERY menuQuery DISPLAY
        menuTable.position      FORMAT ">9"    LABEL "LN"
        menuTable.description   FORMAT "X(30)" LABEL "DESCRIPTION"
        menuTable.function_name FORMAT "X(14)" LABEL "FUNCTION"
        WITH 18 DOWN NO-BOX NO-LABELS
        .
        
    DEFINE FRAME menuFrame
        menuBrowse HELP " "
      WITH NO-LABELS NO-BOX.
      
    CONSTRUCTOR menuForm():
        cMenuApi = NEW menuApi().
    END.

    DESTRUCTOR menuForm():
        DELETE OBJECT cMenuApi NO-ERROR.
    END.

    METHOD PUBLIC CHARACTER showMenu():
        SUPER:showHeader().
        VIEW FRAME headerFrame. PAUSE 0.
    END.

    METHOD PUBLIC CHARACTER recordset():
        DEFINE VARIABLE menuHandle AS HANDLE.
        
        menuHandle = menuTab:HANDLE.
        
        RETURN cMenuApi:getData(0, 0, TABLE menuHandle BIND).
    END.

    ON RETURN OF menuFrame
     DO:
        IF NOT AVAILABLE menuTable THEN RETURN.
        
        RETURN cMenuApi:getData(menuTable.id, 0, TABLE menuTable BIND).
     END.
     
    
END.