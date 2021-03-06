USING system.api.currency.*.
USING system.api.systemSettings.*.

CLASS system.api.currency.currencyApi: 
    {propertyGetSet.f &name="nationalCurrency" &type="CHARACTER" &static="static"}
    
    CONSTRUCTOR STATIC currencyApi():
        nationalCurrency = "EUR".
    END.

    METHOD PUBLIC STATIC DECIMAL getBuyRate(iCurrency AS CHARACTER):
        RETURN getRate(globalSettings:balance_date, iCurrency, "BUY").
    END.
    
    METHOD PUBLIC STATIC DECIMAL getBuyRate(iBalanceDate AS DATE, iCurrency AS CHARACTER):
        RETURN getRate(iBalanceDate, iCurrency, "BUY").
    END.
    
    METHOD PUBLIC STATIC DECIMAL getSellRate(iCurrency AS CHARACTER):
        RETURN getRate(globalSettings:balance_date, iCurrency, "SELL").
    END.
    
    METHOD PUBLIC STATIC DECIMAL getSellRate(iBalanceDate AS DATE, iCurrency AS CHARACTER):
        RETURN getRate(iBalanceDate, iCurrency, "SELL").
    END.

    METHOD PUBLIC STATIC DECIMAL getCentralBankRate(iBalanceDate AS DATE, iCurrency AS CHARACTER):
        RETURN getRate(iBalanceDate, iCurrency, "ECB").
    END.

    DEFINE STATIC VARIABLE lastCurrency AS CHARACTER NO-UNDO.
    DEFINE STATIC VARIABLE lastDate     AS DATE      NO-UNDO.
    DEFINE STATIC VARIABLE lastType     AS CHARACTER NO-UNDO.
    DEFINE STATIC VARIABLE lastRate     AS DECIMAL   NO-UNDO.
    
    METHOD PRIVATE STATIC DECIMAL getChachedRate(iBalanceDate AS DATE, iCurrency AS CHARACTER, iRateType AS CHARACTER):
        IF     lastType     = iRateType
           AND lastCurrency = iCurrency
           AND lastDate     = iBalanceDate THEN RETURN lastRate.
        RETURN 0.
    END.
    
    METHOD PUBLIC STATIC INT64 getCurrencyId(iCurrency AS CHARACTER):
        DEFINE BUFFER currency FOR currency.
        
        FIND FIRST currency NO-LOCK WHERE currency.currency     = iCurrency
                                 NO-ERROR.
        IF AVAILABLE currency THEN RETURN currency.id.
        
        RETURN 0.
    END.
    
    METHOD PUBLIC STATIC INT64 getCurrencyRateId(iBalanceDate AS DATE, iCurrency AS CHARACTER, iRateType AS CHARACTER):
        DEFINE BUFFER currency_rates FOR currency_rates.
        
        FIND LAST currency_rates NO-LOCK WHERE currency_rates.rate_type         = iRateType
                                                AND currency_rates.currency     = iCurrency
                                                AND currency_rates.balance_date = iBalanceDate
                                                NO-ERROR.
        IF AVAILABLE currency_rates THEN  RETURN currency_rates.id.
        
        RETURN 0.
    END.
    
    METHOD PUBLIC STATIC DECIMAL getRate(iBalanceDate AS DATE, iCurrency AS CHARACTER, iRateType AS CHARACTER):
        DEFINE BUFFER currency_rates FOR  currency_rates.
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oRate  AS DECIMAL   NO-UNDO.
        
        oRate = getChachedRate(iBalanceDate, iCurrency, iRateType).
        IF oRate > 0 THEN RETURN oRate.

        DO TRANSACTION ON ERROR UNDO, THROW:

            FIND LAST currency_rates NO-LOCK WHERE currency_rates.rate_type     = iRateType
                                                AND currency_rates.currency     = iCurrency
                                                AND currency_rates.balance_date <= iBalanceDate
                                                NO-ERROR.
            IF AVAILABLE currency_rates THEN 
             DO:
                lastType        = currency_rates.rate_type.
                lastCurrency    = currency_rates.currency.
                lastDate        = currency_rates.balance_date.
                lastRate        = currency_rates.rate / currency_rates.unit.
                
                RETURN lastRate.
             END.
             
            oError = SUBSTITUTE("Currency rate [&3] for &1 at &2 not found!", iCurrency, iBalanceDate, iRateType).
            UNDO, THROW NEW Progress.Lang.AppError(oError, 501).
            
            FINALLY:
                RETURN lastRate.
            END.
        END.
        
        RETURN lastRate.
    END.

END.