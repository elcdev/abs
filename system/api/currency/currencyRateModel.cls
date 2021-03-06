USING system.api.currency.*.
USING system.api.core.*.
USING system.api.systemSettings.*.

CLASS system.api.currency.currencyRateModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="currency"            &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="balance_date"        &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="rate_type"           &type="CHAR" &serializable="serializable"}
    {propertyGetSet.f &name="rate"                &type="DEC"  &serializable="serializable"}
    {propertyGetSet.f &name="count"               &type="DEC"  &serializable="serializable"}

    {dbModelJsonParser.f &class="system.api.currency.currencyRateModel"}
    {dbModelPutGetMethods.f &TABLE="currency_rates"}
    
    METHOD PUBLIC OVERRIDE CHARACTER prepare():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        
        tId = currencyApi:getCurrencyRateId(balance_date, currency, rate_type).
        IF tId > 0 AND id = 0 THEN id = tId. /* TODO! */
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER getDbByCurrency(iCurrency AS CHARACTER, iBalanceDay AS DATE, iRateType AS CHARACTER):
        DEFINE VARIABLE iId AS INT64 NO-UNDO.
        DEFINE BUFFER currency_rates FOR currency_rates.
        
        FIND LAST currency_rates NO-LOCK WHERE currency_rates.currency      = iCurrency 
                                            AND currency_rates.balance_date = iBalanceDay  /* Must be equal */
                                            AND currency_rates.rate_type    = iRateType
                                            NO-ERROR.
        IF AVAILABLE currency_rates THEN iId = currency_rates.id.
        
        RETURN getDb(iId).
    END.

END.