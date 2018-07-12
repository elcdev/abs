CLASS menuTableRequest inherits requestBase IMPLEMENTS dbInterface:
    {menuTable.i}
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f munu}
        
        position      = munu.position.
        functionName  = munu.functionName.
        procedureName = munu.procedureName.
        slug          = munu.slug.
        description   = munu.description.
        
        RETURN "".
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
	
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
        {requestItemGetDb.f munu}
        
        position      = munu.position.
        functionName  = munu.functionName.
        procedureName = munu.procedureName.
        slug          = munu.slug.
        description   = munu.description.
        
        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.