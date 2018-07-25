CLASS menuApi INHERITS apiBase:
    {menuTable.i}

    METHOD PUBLIC CHARACTER getData (parent_id AS INT64, TABLE menuTable BIND):
        DEFINE BUFFER menu FOR menu.
        
        FOR EACH menu NO-LOCK WHERE menu.parent_id = parent_id:
            CREATE menuTable.
            BUFFER-COPY menu TO menuTable.
        END.
        
        RETURN "".
    END.

    METHOD PUBLIC CHARACTER getData (searchString AS CHAR, iTop AS INT64, TABLE menuTable BIND):
        DEFINE BUFFER menu FOR menu.
        DEFINE VARIABLE i AS INT64 NO-UNDO INITIAL 0.
        
        EMPTY TEMP-TABLE menuTable.
        
        FOR EACH menu NO-LOCK WHERE menu.function_name MATCHES "*" + searchString + "*":
            CREATE menuTable.
            BUFFER-COPY menu TO menuTable.
            i = i + 1.
            IF i > iTop AND iTop > 0 THEN LEAVE.
        END.

        FOR EACH menu NO-LOCK WHERE menu.description MATCHES "*" + searchString + "*":
            CREATE menuTable.
            BUFFER-COPY menu TO menuTable.
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
        /*garbage:addItem(tMenu).*/
        
        RETURN tMenu.
    END.

    METHOD PUBLIC menuItemModel getMenuItem(iFunction AS CHAR):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iFunction) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iFunction).
        /*garbage:addItem(tMenu).*/
        
        RETURN tMenu.
    END.
    
END CLASS.