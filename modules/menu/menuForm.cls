USING system.api.systemSettings.*.
USING system.api.core.*.
USING system.api.menu.*.
USING modules.menu.*.

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

CLASS modules.menu.menuForm INHERITS headerForm:
    DEFINE VARIABLE cMenuApi AS menuApi NO-UNDO.
    {menuTable.i}
    DEFINE VARIABLE parentId      AS INT64     NO-UNDO INITIAL 0.
    
    DEFINE QUERY formQuery FOR formTable.

    DEFINE BROWSE formBrowse QUERY formQuery DISPLAY
        formTable.position      FORMAT ">9"    LABEL "LN"
        formTable.description   FORMAT "X(55)" LABEL "DESCRIPTION"
        formTable.function_name FORMAT "X(15)" LABEL "FUNCTION"
        "> "                    FORMAT "XX"    LABEL "SB"
        WITH 19 DOWN NO-LABELS NO-SCROLLBAR-VERTICAL
        SIZE 80 BY 18 
        .
        
    DEFINE FRAME formFrame
        formBrowse HELP " " SKIP
      WITH NO-LABELS NO-BOX SIZE 80 BY 20 OVERLAY ROW 2 
      CENTERED.

    DEFINE FRAME formShadow
      WITH NO-LABELS NO-BOX SIZE 80 BY 20 OVERLAY ROW 2
      CENTERED.

    {formBrowserBaseMethods.f &formTable="formTable"}
    
    CONSTRUCTOR menuForm():
        cMenuApi = NEW menuApi().
        ENABLE-SHADOW = FALSE.
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
        SUPER:showHeader().
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
        cMenuApi:getData(tmpFormId, INPUT-OUTPUT TABLE formTable).
        openQuery().
        RETURN "".
    END.
    
    ON RETURN OF formBrowse
     DO:
        DEFINE VARIABLE tMenu AS menuItemModel.
        
        IF NOT AVAILABLE formTable THEN RETURN.
        /* TODO */
        IF formTable.action = "" THEN 
         DO:
            cMenuApi:getData(formTable.parent_id, INPUT-OUTPUT TABLE formTable).
            openQuery().
         END.
        ELSE IF formTable.action = "run" THEN 
         DO:
            tMenu = cMenuApi:getModel(formTable.id).
            RUN VALUE(formTable.procedure_name) (tMenu).
            DELETE OBJECT tMenu NO-ERROR.
         END.
        ELSE IF formTable.action = "proc" THEN 
         DO:
            RUN VALUE(formTable.procedure_name).
         END.
        
        RETURN "".
     END.
    
    ON INSERT OF formBrowse
     DO:
        editItem(0).
     END.
     
    ON F6 OF formBrowse
     DO:
        IF NOT AVAILABLE formTable THEN RETURN.
        editItem(formTable.id).
     END.

    METHOD PRIVATE CHARACTER editItem(iId AS INT64):
        DEFINE VARIABLE editForm AS menuEditForm.
        
        DisableForm().
        
        editForm = NEW menuEditForm().
        editForm:recordset(iId).
        editForm:showForm().
        IF editForm:dataChanged THEN recordset().
        DELETE OBJECT editForm.
        
        showFrame().
        showData().
        RETURN "".        
    END.
END.
