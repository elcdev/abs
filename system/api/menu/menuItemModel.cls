CLASS menuItemModel inherits dbModel IMPLEMENTS dbInterface:
    DEFINE PUBLIC VARIABLE parent_id     AS INT64     NO-UNDO.
    DEFINE PUBLIC VARIABLE position      AS INTEGER   NO-UNDO.
	DEFINE PUBLIC VARIABLE functionName  AS CHARACTER NO-UNDO.
	DEFINE PUBLIC VARIABLE procedureName AS CHARACTER NO-UNDO.
	DEFINE PUBLIC VARIABLE slug          AS CHARACTER NO-UNDO.
	DEFINE PUBLIC VARIABLE description   AS CHARACTER NO-UNDO.
	
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f menu}
        
        menu.parent_id      = parent_id.
        menu.position       = position.
        menu.function_name  = functionName.
        menu.procedure_name = procedureName.
        menu.slug           = slug.
        menu.description    = description.
        
        RETURN "".
	END.
	
    METHOD PUBLIC OVERRIDE CHARACTER getDb():
        RETURN getDb(id).
    END.
    
	METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDb.f menu}
        
        parent_id     = menu.parent_id.
        position      = menu.position.
        functionName  = menu.function_name.
        procedureName = menu.procedure_name.
        slug          = menu.slug.
        description   = menu.description.
        
        RETURN "".
	END.
	
    METHOD PUBLIC INT64 getIdByFunctionName(iFunction AS CHAR):
        DEFINE BUFFER menu FOR menu.

        FOR EACH menu NO-LOCK WHERE menu.function_name = iFunction USE-INDEX function_name:
            RETURN menu.id.
        END.
        
        RETURN 0.
    END.
    
    METHOD PUBLIC CHARACTER getDb(iFunction AS CHAR):
        RETURN getDb(getIdByFunctionName(iFunction)).
    END.
    
	METHOD PUBLIC OVERRIDE CHARACTER getJson():
	
	END.
	
END CLASS.