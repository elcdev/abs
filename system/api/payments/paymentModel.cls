CLASS paymentModel:
    {propertyGetSet.f &name="header_id"      &type="int64"}
    {propertyGetSet.f &name="line"           &type="INTEGER"}
    {propertyGetSet.f &name="line_status"    &type="INTEGER"}
    {propertyGetSet.f &name="line_type"      &type="CHARACTER"}
    {propertyGetSet.f &name="gl"             &type="INT64"}
    {propertyGetSet.f &name="account"        &type="CHARACTER"}
    {propertyGetSet.f &name="balance_date"   &type="DATE"}
    {propertyGetSet.f &name="currency"       &type="CHARACTER"}
    
    {propertyGetSet.f &name="dc"             &type="CHAR"}
    {propertyGetSet.f &name="debet"          &type="DECIMAL"}
    {propertyGetSet.f &name="credit"         &type="DECIMAL"}
    {propertyGetSet.f &name="details"        &type="CHARACTER"}
    {propertyGetSet.f &name="create_user"    &type="CHARACTER"}
    {propertyGetSet.f &name="authorize_user" &type="CHARACTER"}
    /*
    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="transaction_line"}
        RETURN setValuesToBuffer(BUFFER transaction_line:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER transaction_line:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByHeader(iHeader_id AS INT64):
        {requestItemGetDbByField.f &table="transaction_line" &field="header_id"}
        RETURN getValuesFromBuffer(BUFFER gl:handle).
    END.
    */
END.