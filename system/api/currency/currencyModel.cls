USING system.api.currency.*.
USING system.api.core.*.
USING system.api.systemSettings.*.

CLASS system.api.currency.currencyModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="currency"            &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="description"         &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="decimal_points"      &type="DEC"  &serializable="serializable"}
    {propertyGetSet.f &name="currency_order"      &type="INT"  &serializable="serializable"}
    {propertyGetSet.f &name="currency_status"     &type="CHAR" &serializable="serializable"}

    {dbModelJsonParser.f &class="system.api.currency.currencyModel"}
    {dbModelPutGetMethods.f &TABLE="currency"}
    
    METHOD PUBLIC CHARACTER getDbByCurrency(iCurrency AS CHAR):
        {requestItemGetDbByField.f &table="currency" &field="currency"}
        RETURN getValuesFromBuffer(BUFFER currency:handle).
    END.

END.