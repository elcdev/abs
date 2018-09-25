	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="{&TABLE}"}
        RETURN setValuesToBuffer(BUFFER {&TABLE}:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="{&TABLE}" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER {&TABLE}:handle).
	END.