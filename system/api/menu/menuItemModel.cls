CLASS menuItemModel inherits dbModel:
    {propertyGetSet.f &name="parent_id"      &type="int64"}
    {propertyGetSet.f &name="position"       &type="INTEGER"}
    {propertyGetSet.f &name="function_name"  &type="CHARACTER"}
    {propertyGetSet.f &name="procedure_name" &type="CHARACTER"}
    {propertyGetSet.f &name="slug"           &type="CHARACTER"}
    {propertyGetSet.f &name="description"    &type="CHARACTER"}
    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="menu"}
        RETURN setValuesToBuffer(BUFFER menu:handle).
	END.
	
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="menu" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER menu:handle).
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
