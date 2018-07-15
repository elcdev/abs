CLASS menuItemRequest inherits requestBase IMPLEMENTS dbInterface:
    DEF VAR position      AS INTEGER NO-UNDO.
	DEF VAR functionName  AS CHAR NO-UNDO.
	DEF VAR procedureName AS CHAR NO-UNDO.
	DEF VAR slug          AS CHAR NO-UNDO.
	DEF VAR description   AS CHAR NO-UNDO.
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f menu}

        position      = menu.position.
        functionName  = menu.functionName.
        procedureName = menu.procedureName.
        slug          = menu.slug.
        description   = menu.description.

        RETURN "".
	END.
	
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
    
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
        {requestItemGetDb.f menu}

        position      = menu.position.
        functionName  = menu.functionName.
        procedureName = menu.procedureName.
        slug          = menu.slug.
        description   = menu.description.

        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.