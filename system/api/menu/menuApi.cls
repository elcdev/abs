CLASS menuApi INHERITS apiBase:
    {menuTable.i}
/*
    METHOD PUBLIC OVERRIDE responseBase invoke(model AS dbModel).
        CASE request:action:
            WHEN "getdb"   THEN response:errorDescription = request:getDb().
            WHEN "putdb"   THEN response:errorDescription = request:putDb().
            WHEN "getjson" THEN response:jsonData         = request:getJson().
        END.
        
        RETURN response.
    END.
*/

<<<<<<< HEAD
/*    
	METHOD PUBLIC CHARACTER getData (filter AS menuFilterModel, TEMP-TABLE menuTable BIND):
        RETURN getData(filter:parent_id, TEMP-TABLE menuTable BIND).
    END.
*/

    METHOD PUBLIC CHARACTER getData (parent_id AS INT64, TEMP-TABLE menuTable BIND):
        DEFINE BUFFER menu FOR menu.
        
        FOR EACH menu NO-LOCK WHERE menu.parent_id = parent_id:
            CREATE menuTable.
            BUFFER-COPY menu TO menuTable.
        END.
        
        RETURN "".
=======
	METHOD PUBLIC CHARACTER getData():
	 
>>>>>>> d6f1b9819a373ef908df8d2637da0e6583a5857f
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
        DEFINE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iId) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iId).
        /*garbage:addItem(tMenu).*/
        
        RETURN tMenu.
    END.

    METHOD PUBLIC menuItemModel getMenuItem(iFunction AS CHAR):
        DEFINE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iFunction) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iFunction).
        /*garbage:addItem(tMenu).*/
        
        RETURN tMenu.
    END.
    
END CLASS.