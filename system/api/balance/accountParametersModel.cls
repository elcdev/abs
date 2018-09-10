CLASS accountParametersModel INHERITS dbModel:
    {propertyGetSet.f &name="gl"                  &type="int64"}
    {propertyGetSet.f &name="iban"                &type="CHAR"}
    {propertyGetSet.f &name="account"             &type="CHAR"}
    {propertyGetSet.f &name="base_account"        &type="CHAR"}
    {propertyGetSet.f &name="overdraft_account"   &type="CHAR"}
    {propertyGetSet.f &name="currency"            &type="CHAR"}
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="account" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER account:handle).
	END.

    METHOD PUBLIC CHARACTER getDb(iAccount AS CHAR):
        {requestItemGetDbByField.f &table="account" &field="Account"}
        RETURN getValuesFromBuffer(BUFFER account:handle).
    END.
    
END.