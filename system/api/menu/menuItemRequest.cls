CLASS menuItemRequest inherits requestBase IMPLEMENTS dbInterface:
    DEF VAR position      AS INTEGER NO-UNDO.
	DEF VAR functionName  AS CHAR NO-UNDO.
	DEF VAR procedureName AS CHAR NO-UNDO.
	DEF VAR slug          AS CHAR NO-UNDO.
	DEF VAR description   AS CHAR NO-UNDO.
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestBaseSetFields.f system_settings}
        
        position      = system_settings.position.
        functionName  = system_settings.functionName.
        procedureName = system_settings.procedureName.
        slug          = system_settings.slug.
        description   = system_settings.description.
        
        RETURN "".
	END.
	
    METHOD PUBLIC CHARACTER getDb():
        RETURN getDb(id).
    END.
    
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
        {requestBaseGetFields.f system_settings}
        
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