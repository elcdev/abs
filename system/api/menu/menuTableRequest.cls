CLASS menuTableRequest inherits requestBase IMPLEMENTS dbInterface:
    {menuTable.i}
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f menu}
        
        position      = menu.position.
        functionName  = menu.function_name.
        procedureName = menu.procedure_name.
        slug          = menu.slug.
        description   = menu.description.

        RETURN "".
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
	
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
        {requestItemGetDb.f menu}
        
        menu.position       = position.
        menu.function_name  = functionName.
        menu.procedure_name = procedureName.
        menu.slug           = slug.
        menu.description    = description.

        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.