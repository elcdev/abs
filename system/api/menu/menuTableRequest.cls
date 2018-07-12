CLASS menuTableRequest inherits requestBase IMPLEMENTS dbInterface:
    {menuTable.i}
	
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