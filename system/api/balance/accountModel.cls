USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

CLASS system.api.balance.accountModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="gl"                  &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="iban"                &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account"             &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="base_account"        &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="overdraft_account"   &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="currency"            &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account_group"       &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="subledger_type"      &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="account_subtype"     &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="product_code"        &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="branch"              &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="cif"                 &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="client_id"           &type="int64" &serializable="serializable"}
    {propertyGetSet.f &name="account_status"      &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="description"         &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="open_date"           &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="close_date"          &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="open_amount"         &type="DEC" &serializable="serializable"}
    {propertyGetSet.f &name="last_operation_date" &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_debet_date"     &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_debet_amount"   &type="DEC" &serializable="serializable"}
    {propertyGetSet.f &name="last_credit_date"    &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="last_credit_amount"  &type="DEC" &serializable="serializable"}

    {dbModelJsonParser.f &class="system.api.balance.accountModel"}
    {dbModelPutGetMethods.f &TABLE="account" &override=""}
    
    METHOD PUBLIC CHARACTER getDbByAccount(iAccount AS CHAR):
        {requestItemGetDbByField.f &table="account" &field="Account"}
        RETURN getValuesFromBuffer(BUFFER account:handle).
    END.



END.