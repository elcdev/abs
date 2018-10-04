USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

CLASS system.api.balance.transactionHeaderModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="header_id"        &type="INT64" &serializable="serializable"}
    {propertyGetSet.f &name="balance_date"     &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="document_id"      &type="INT64" &serializable="serializable"}
    {propertyGetSet.f &name="deal_number"      &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="head_status"      &type="INTEGER" &serializable="serializable"}
    {propertyGetSet.f &name="authorize_user"   &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="authorize_date"   &type="DATE" &serializable="serializable"}

    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_header" &sequence_id="transaction_id"}
        RETURN setValuesToBuffer(BUFFER transaction_header:handle).
	END.

    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_header" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_header:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_header" &field="header_id"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER prepare():
        IF balance_date  = ? THEN balance_date = globalSettings:balance_date.
        IF header_id = 0     THEN header_id = NEXT-VALUE(transaction_header_id).
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER initDefaultSettings():
        prepare().
        balance_date = globalSettings:balance_date.
        RETURN "".
    END.    
    
 END.