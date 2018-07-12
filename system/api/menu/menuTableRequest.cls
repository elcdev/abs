CLASS menuTableRequest inherits requestBase IMPLEMENTS dbInterface:
    {menuTable.i}
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f system_settings}
        
        position      = system_settings.position.
        functionName  = system_settings.functionName.
        procedureName = system_settings.procedureName.
        slug          = system_settings.slug.
        description   = system_settings.description.
        
        RETURN "".
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT):
        {requestItemGetDb.f system_settings}
        
        position      = system_settings.position.
        functionName  = system_settings.functionName.
        procedureName = system_settings.procedureName.
        slug          = system_settings.slug.
        description   = system_settings.description.
        
        RETURN "".
	END.
	
	METHOD PUBLIC CHARACTER getJson():
	
	END.
	
END CLASS.