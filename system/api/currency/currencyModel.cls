USING system.api.currency.*.
USING system.api.core.*.
USING system.api.systemSettings.*.

CLASS system.api.currency.currencyModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="currency"            &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="description"         &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="decimal_points"      &type="DEC"  &serializable="serializable"}
    {propertyGetSet.f &name="currency_order"      &type="INT"  &serializable="serializable"}
    {propertyGetSet.f &name="currency_status"     &type="CHAR" &serializable="serializable"}

    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="currency"}
        RETURN setValuesToBuffer(BUFFER currency:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="currency" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER currency:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByCurrency(iCurrency AS CHAR):
        {requestItemGetDbByField.f &table="currency" &field="currency"}
        RETURN getValuesFromBuffer(BUFFER currency:handle).
    END.

END.