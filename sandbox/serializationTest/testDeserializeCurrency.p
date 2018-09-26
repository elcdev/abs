USING system.api.*.
USING system.api.core.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.
USING system.api.currency.*.
USING Progress.IO.*.

DEFINE VARIABLE myObj     AS currencyModel.
DEFINE VARIABLE apiCall   AS CHARACTER.
DEFINE VARIABLE className AS CHARACTER.
DEFINE VARIABLE json      AS LONGCHAR.
/*
myObj = new currencyModel().
myObj:getDbByCurrency("EUR").
myObj:toJsonFile("C:\Projects\abs\sandbox\testDynmicProperties\currency.json").
*/
apiCall = "update.currency".
className = apiHelper:getClassName(apiCall).
COPY-LOB FILE "C:\Projects\abs\sandbox\testDynmicProperties\currency.json" TO json.
myObj = DYNAMIC-CAST(apiHelper:getApiModel(apiCall, json), className).

MESSAGE myObj:currency SKIP 
        myObj:id SKIP
        VIEW-AS ALERT-BOX.

