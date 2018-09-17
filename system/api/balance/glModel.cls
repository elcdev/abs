CLASS glModel INHERITS dbModel:
    {propertyGetSet.f &name="gl"                  &type="INT64"}
    {propertyGetSet.f &name="parent_gl"           &type="INT64"}
    {propertyGetSet.f &name="description"         &type="CHAR"}
    {propertyGetSet.f &name="gl_type"             &type="CHAR"}
    {propertyGetSet.f &name="subledger_type"      &type="CHAR"}
    {propertyGetSet.f &name="gl_status"           &type="CHAR"}
    {propertyGetSet.f &name="level"               &type="INT"}
    {propertyGetSet.f &name="total_action"        &type="LOGICAL"}
    {propertyGetSet.f &name="restrict_operation"  &type="LOGICAL"}
    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="gl"}
        RETURN setValuesToBuffer(BUFFER gl:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="gl" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER gl:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByGl(iGl AS INT64):
        {requestItemGetDbByField.f &table="gl" &field="gl"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.

END.