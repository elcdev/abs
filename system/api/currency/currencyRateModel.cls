CLASS currencyRateModel INHERITS dbModel:
    {propertyGetSet.f &name="currency"            &type="CHAR"}
    {propertyGetSet.f &name="balance_date"        &type="DATE"}
    {propertyGetSet.f &name="rate_type"           &type="CHAR"}
    {propertyGetSet.f &name="rate"                &type="DEC"}
    {propertyGetSet.f &name="count"               &type="DEC"}

    
	METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="currency_rates"}
        RETURN setValuesToBuffer(BUFFER currency_rates:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="currency_rates" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER currency_rates:handle).
	END.

    METHOD PUBLIC CHARACTER getDbByCurrency(iCurrency AS CHARACTER, iBalanceDay AS DATE, iRateType AS CHARACTER):
        DEFINE VARIABLE iId AS INT64 NO-UNDO.
        DEFINE BUFFER currency_rates FOR currency_rates.
        
        FIND FIRST currency_rates NO-LOCK WHERE currency_rates.currency     = iCurrency 
                                            AND currency_rates.balance_date = iBalanceDay 
                                            AND currency_rates.rate_type    = iRateType
                                            NO-ERROR.
        IF AVAILABLE currency_rates THEN iId = currency_rates.id.
        
        RETURN getDb(iId).
    END.

END.