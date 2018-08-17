CLASS menuApi INHERITS apiBase:
    {menuTable.i}

    METHOD PUBLIC CHARACTER getData (parent_id AS INT64, INPUT-OUTPUT TABLE formTable):
        DEFINE BUFFER menu FOR menu.
        
        EMPTY TEMP-TABLE formTable.
        
        FOR EACH menu NO-LOCK WHERE menu.parent_id = parent_id:
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
        END.
        
        RETURN "".
    END.

    METHOD PUBLIC CHARACTER getData (searchString AS CHAR, iTop AS INT64, INPUT-OUTPUT TABLE formTable):
        DEFINE BUFFER menu FOR menu.
        DEFINE VARIABLE i AS INT64 NO-UNDO INITIAL 0.
        
        EMPTY TEMP-TABLE formTable.
        
        FOR EACH menu NO-LOCK WHERE menu.function_name MATCHES "*" + searchString + "*":
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
            i = i + 1.
            IF i > iTop AND iTop > 0 THEN LEAVE.
        END.

        FOR EACH menu NO-LOCK WHERE menu.description MATCHES "*" + searchString + "*":
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
            i = i + 1.
            IF i > iTop AND iTop > 0 THEN LEAVE.
        END.
        
        RETURN "".
    END.
    
    METHOD PUBLIC LOG existsMenuItem(iId AS INT64):
        DEFINE BUFFER menu FOR menu.

        FOR EACH menu NO-LOCK WHERE menu.id = iId USE-INDEX id:
            RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.
    
    METHOD PUBLIC LOG existsMenuItem(iFunction AS CHAR):
        DEFINE BUFFER menu FOR menu.

        FOR EACH menu NO-LOCK WHERE menu.function_name = iFunction USE-INDEX function_name:
            RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.
    
    METHOD PUBLIC menuItemModel getMenuItem(iId AS INT64):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iId) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iId).
        garbage:addItem(tMenu).
        
        RETURN tMenu.
    END.

    METHOD PUBLIC menuItemModel getMenuItem(iFunction AS CHAR):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iFunction) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iFunction).
        garbage:addItem(tMenu).
        
        RETURN tMenu.
    END.
    
END CLASS.