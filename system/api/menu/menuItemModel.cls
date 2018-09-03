CLASS menuItemModel inherits dbModel:
    {propertyGetSet.f &name="parent_id"      &type="int64"}
    {propertyGetSet.f &name="position"       &type="INTEGER"}
    {propertyGetSet.f &name="function_name"  &type="CHARACTER"}
    {propertyGetSet.f &name="procedure_name" &type="CHARACTER"}
    {propertyGetSet.f &name="slug"           &type="CHARACTER"}
    {propertyGetSet.f &name="description"    &type="CHARACTER"}

    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f menu}
        
        menu.parent_id      = parent_id.
        menu.position       = position.
        menu.function_name  = function_name.
        menu.procedure_name = procedure_name.
        menu.slug           = slug.
        menu.description    = description.

        RETURN "".
	END.
	
	METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDb.f menu}
        
        parent_id     = menu.parent_id.
        position      = menu.position.
        function_name  = menu.function_name.
        procedure_name = menu.procedure_name.
        slug          = menu.slug.
        description   = menu.description.
        
        RETURN "".
	END.
	/*
	METHOD PUBLIC CHARACTER setValuesFromBuffer(hMenuBuffer AS HANDLE):
        DEFINE VARIABLE i      AS INT64  NO-UNDO INITIAL 0.   
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.
        
        DO i = 1 TO hMenuBuffer:NUM-FIELDS:
            hField = hMenuBuffer:BUFFER-FIELD(i).
            DYNAMIC-PROPERTY(THIS-OBJECT, hField:NAME) = hField:BUFFER-VALUE.
        END.
        
        RETURN "".
	END.
    */
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
