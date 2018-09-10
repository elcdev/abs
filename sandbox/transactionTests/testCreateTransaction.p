DEFINE VARIABLE cTransactionApi AS transactionApi.
DEFINE VARIABLE cTrDebetLine    AS transactionLineModel.
DEFINE VARIABLE cTrCreditLine   AS transactionLineModel.
DEFINE VARIABLE cTrHeader       AS transactionHeaderModel.
DEFINE VARIABLE tDetails        AS CHARACTER NO-UNDO.
DEFINE VARIABLE oError          AS CHARACTER.

cTransactionApi = NEW transactionApi().

oError = cTransactionApi:createHeader(cTrHeader).
IF oError <> "" THEN
 DO:
    MESSAGE oError VIEW-AS ALERT-BOX.
    RETURN.
 END.

cTrDebetLine  = cTransactionApi:createLineModel().
cTrCreditLine = cTransactionApi:createLineModel().

tDetails = "Test transaction for date %balnce_date%".

oError = cTrDebetLine:setLineData("A100000", "D", 1000, "EUR", tDetails).
IF oError <> "" THEN
 DO:
    MESSAGE "Debet line error:" SKIP oError VIEW-AS ALERT-BOX.
    RETURN.
 END.

 
oError = cTrCreditLine:setLineData("A200000", "C", 1000, "EUR", tDetails).

oError = cTransactionApi:createLine(cTrDebetLine).
IF oError <> "" THEN
 DO:
    MESSAGE oError VIEW-AS ALERT-BOX.
    RETURN.
 END.   

/* auhorize transaction */
cTransactionApi:authorizeTransaction(cTrHeader).

/**/
/* cTransactionApi:acceptTransaction(). */

/* */