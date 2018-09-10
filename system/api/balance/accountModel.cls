CLASS accountModel INHERITS dbModel:
    {propertyGetSet.f &name="gl"                  &type="int64"}
    {propertyGetSet.f &name="iban"                &type="CHAR"}
    {propertyGetSet.f &name="account"             &type="CHAR"}
    {propertyGetSet.f &name="base_account"        &type="CHAR"}
    {propertyGetSet.f &name="overdraft_account"   &type="CHAR"}
    {propertyGetSet.f &name="currency"            &type="CHAR"}
    {propertyGetSet.f &name="account_group"       &type="CHAR"}
    {propertyGetSet.f &name="subledger_type"      &type="CHAR"}
    {propertyGetSet.f &name="account_subtype"     &type="CHAR"}
    {propertyGetSet.f &name="product_code"        &type="CHAR"}
    {propertyGetSet.f &name="branch"              &type="CHAR"}
    {propertyGetSet.f &name="cif"                 &type="CHAR"}
    {propertyGetSet.f &name="client_id"           &type="int64"}
    {propertyGetSet.f &name="account_status"      &type="CHAR"}
    {propertyGetSet.f &name="description"         &type="CHAR"}
    {propertyGetSet.f &name="open_date"           &type="DATE"}
    {propertyGetSet.f &name="close_date"          &type="DATE"}
    {propertyGetSet.f &name="open_amount"         &type="DEC"}
    {propertyGetSet.f &name="last_operation_date" &type="DATE"}
    {propertyGetSet.f &name="last_debet_date"     &type="DATE"}
    {propertyGetSet.f &name="last_debet_amount"   &type="DEC"}
    {propertyGetSet.f &name="last_credit_date"    &type="DATE"}
    {propertyGetSet.f &name="last_credit_amount"  &type="DEC"}
    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="account"}
        RETURN setValuesToBuffer(BUFFER account:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="account" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER account:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByAccount(iAccount AS CHAR):
        {requestItemGetDbByField.f &table="account" &field="Account"}
        RETURN getValuesFromBuffer(BUFFER account:handle).
    END.

END.