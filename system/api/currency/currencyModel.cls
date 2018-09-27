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

    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        {requestItemPutDb.f &TABLE="currency"}
        
        /* TODO! Move into include */
        oError = validate().
        IF oError <> "" THEN RETURN oError.
        
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

    METHOD PUBLIC OVERRIDE CHARACTER prepare():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        
        tId = currencyApi:getCurrencyId(currency).
        IF tId > 0 AND id = 0 THEN id = tId. /* TODO! */
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER validate():
        DEFINE VARIABLE tId    AS INT64 NO-UNDO.
        DEFINE VARIABLE oError AS CHARACTER.
        
        DO ON ERROR UNDO, THROW:
            IF currency = "" OR currency = ? OR LENGTH(currency) < 3 THEN UNDO, THROW NEW Progress.Lang.AppError("ERROR-CURRENCY-CODE, Currency code incorrect!", 501).
            
            /* Check if currency exists */
            tId = currencyApi:getIdByCurrency(currency).
            IF tId > 0 AND tId <> id AND id > 0 THEN DO:
                oError = "ERROR-CURRENCY-ID, Currency id already exists for other code!".
                UNDO, THROW NEW Progress.Lang.AppError(oError, 502).
            END.
        END.
        
        RETURN oError.
    END.
END.