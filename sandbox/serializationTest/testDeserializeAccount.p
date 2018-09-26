USING system.api.*.
USING system.api.core.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.
USING Progress.IO.*.

DEFINE VARIABLE myObj     AS accountModel.
DEFINE VARIABLE apiCall   AS CHARACTER.
DEFINE VARIABLE className AS CHARACTER.
DEFINE VARIABLE json      AS LONGCHAR.

apiCall = "update.account".
className = apiHelper:getClassName(apiCall).
COPY-LOB FILE "C:\Projects\abs\sandbox\testDynmicProperties\account.json" TO json.
myObj = DYNAMIC-CAST(apiHelper:getApiModel(apiCall, json), className).

MESSAGE myObj:account SKIP
        myObj:currency SKIP 
        myObj:id SKIP
        VIEW-AS ALERT-BOX.

