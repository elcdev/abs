CLASS currencyModel INHERITS dbModel:
    {propertyGetSet.f &name="currency"            &type="CHAR"}
    {propertyGetSet.f &name="description"         &type="CHAR"}
    {propertyGetSet.f &name="decimal_points"      &type="DEC"}
    {propertyGetSet.f &name="currency_order"      &type="INT"}
    {propertyGetSet.f &name="currency_status"     &type="CHAR"}

    
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