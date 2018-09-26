USING system.api.systemSettings.*.
USING system.api.core.*.
USING system.api.menu.*.

CLASS system.api.menu.menuItemModel SERIALIZABLE inherits dbModel:
    {propertyGetSet.f &name="parent_id"      &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="position"       &type="INTEGER" &serializable="serializable"}
    {propertyGetSet.f &name="function_name"  &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="procedure_name" &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="slug"           &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="description"    &type="CHARACTER" &serializable="serializable"}
    
    {dbModelJsonParser.f &class="system.api.menu.menuItemModel"}
    {dbModelPutGetMethods.f &TABLE="menu"}
    
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
