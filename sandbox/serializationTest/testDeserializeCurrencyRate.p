USING system.api.*.
USING system.api.core.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.
USING system.api.currency.*.
USING Progress.IO.*.

DEFINE VARIABLE myObj     AS dbInterface.
DEFINE VARIABLE apiCall   AS CHARACTER.
DEFINE VARIABLE className AS CHARACTER.
DEFINE VARIABLE json      AS LONGCHAR.

/*
myObj = new currencyRateModel().
myObj:getDbByCurrency("EUR", TODAY, "ECB").
myObj:toJsonFile("C:\Projects\abs\sandbox\testDynmicProperties\currency.rate.json").
*/
apiCall = "update.currency.rate".
className = apiHelper:getClassName(apiCall).
COPY-LOB FILE "C:\Projects\abs\sandbox\testDynmicProperties\currency.rate.json" TO json.
myObj = DYNAMIC-CAST(apiHelper:getApiModel(apiCall, json), className).
/*
MESSAGE myObj:currency SKIP 
        myObj:balance_date SKIP
        myObj:rate SKIP
        myObj:COUNT SKIP
        myObj:rate_type
        VIEW-AS ALERT-BOX.
*/
MESSAGE myObj:putDb().
PAUSE.

FOR EACH currency_rates:
    DISPLAY currency_rates.
    PAUSE.
END.
