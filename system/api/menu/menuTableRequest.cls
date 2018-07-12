CLASS menuTableRequest inherits requestBase IMPLEMENTS dbInterface:
    {menuTable.i}
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
<<<<<<< HEAD
        {requestItemPutDb.f menu}
        
        position      = menu.position.
        functionName  = menu.functionName.
        procedureName = menu.procedureName.
        slug          = menu.slug.
        description   = menu.description.
=======
        {requestItemPutDb.f munu}
        
        position      = munu.position.
        functionName  = munu.functionName.
        procedureName = munu.procedureName.
        slug          = munu.slug.
        description   = munu.description.
>>>>>>> f835624f38be1e79d12f28192beb22f8f61c7096
        
        RETURN "".
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
	
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
<<<<<<< HEAD
        {requestItemGetDb.f menu}
        
        position      = menu.position.
        functionName  = menu.functionName.
        procedureName = menu.procedureName.
        slug          = menu.slug.
        description   = menu.description.
=======
        {requestItemGetDb.f munu}
        
        position      = munu.position.
        functionName  = munu.functionName.
        procedureName = munu.procedureName.
        slug          = munu.slug.
        description   = munu.description.
>>>>>>> f835624f38be1e79d12f28192beb22f8f61c7096
        
        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.