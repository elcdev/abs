CLASS transactionHeaderModel INHERITS dbModel:
    {propertyGetSet.f &name="header_id"        &type="int64"}
    {propertyGetSet.f &name="balance_date"     &type="DATE"}
    {propertyGetSet.f &name="document_id"      &type="INT64"}
    {propertyGetSet.f &name="deal_number"      &type="CHARACTER"}
    {propertyGetSet.f &name="head_status"      &type="INTEGER"}
    {propertyGetSet.f &name="authorize_user"   &type="CHARACTER"}
    {propertyGetSet.f &name="authorize_date"   &type="DATE"}

    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_header"}
        RETURN setValuesToBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_header" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_header" &field="id"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.
 END.