USING system.api.stomp.*.
USING www.system.types.*.
USING system.api.core.*.
USING system.api.*.

DEFINE INPUT PARAMETER iQueue AS CHARACTER. /* example: "/queue/currencyUpdates" */

DEFINE VARIABLE myStomp AS stompConnector.

PAUSE 0 BEFORE-HIDE.

myStomp = new stompConnector().
myStomp:startQueueListener(iQueue, "messagehandler", this-procedure).
DELETE OBJECT myStomp NO-ERROR.

PROCEDURE messagehandler:
    DEFINE INPUT  PARAM iHeaders AS stringArrayType NO-UNDO.
    DEFINE INPUT  PARAM iMessage AS LONGCHAR        NO-UNDO.
    DEFINE OUTPUT PARAM oError   AS CHARACTER       NO-UNDO.

    DEFINE VARIABLE tObject   AS dbInterface.
    DEFINE VARIABLE apiCall   AS CHARACTER.
    DEFINE VARIABLE className AS CHARACTER.

    DO ON ERROR UNDO, THROW:
        apiCall = iHeaders:item("apiCall").
        className = apiHelper:getClassName(apiCall).
        IF className = "" THEN UNDO, THROW NEW Progress.Lang.AppError ("ERROR-UNKNOWN-APICALL, Class not found", 1).
        
        tObject = DYNAMIC-CAST(apiHelper:getApiModel(apiCall, iMessage), className).
        oError = tObject:putDb().
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError, 1).
    END.
    MESSAGE "apiCall:" apiCall SKIP "Executed!" SKIP PROGRAM-NAME(1) SKIP PROGRAM-NAME(2) VIEW-AS ALERT-BOX.
END PROCEDURE. /* messagehandler */

