DEFINE VARIABLE cTransactionApi AS transactionApi.
DEFINE VARIABLE cTrDebetLine    AS transactionLineModel.
DEFINE VARIABLE cTrCreditLine   AS transactionLineModel.
DEFINE VARIABLE cTrHeader       AS transactionHeaderModel.
DEFINE VARIABLE tDetails        AS CHARACTER NO-UNDO.
DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.

RUN startupSettings.p. 

cTransactionApi = NEW transactionApi().

oError = cTransactionApi:createHeader(INPUT-OUTPUT cTrHeader).
IF oError <> "" THEN
 DO:
    MESSAGE oError VIEW-AS ALERT-BOX.
    RETURN.
 END.

cTrDebetLine  = cTransactionApi:createLineModel(cTrHeader).
cTrCreditLine = cTransactionApi:createLineModel(cTrHeader).

tDetails = "Test transaction for date %balnce_date%".

cTrDebetLine:gl = 101000.

oError = cTrDebetLine:setLineData("A100000", "D", 1000, "EUR", tDetails).
IF oError <> "" THEN
 DO:
    MESSAGE "Debet line error:" SKIP oError VIEW-AS ALERT-BOX.
    RETURN.
 END.
 
MESSAGE cTrDebetLine:getAccount:account cTrDebetLine:getGlAccount:gl cTrDebetLine:getAccount:currency
    VIEW-AS ALERT-BOX.


oError = cTrCreditLine:setLineData("A200000", "C", 1000, "EUR", tDetails).
IF oError <> "" THEN
 DO:
    MESSAGE "Debet line error:" SKIP oError VIEW-AS ALERT-BOX.
    RETURN.
 END.
 
oError = cTransactionApi:createLine(cTrDebetLine).
IF oError <> "" THEN
 DO:
    MESSAGE "Create debet line" SKIP oError VIEW-AS ALERT-BOX.
    RETURN.
 END.   

oError = cTransactionApi:createLine(cTrCreditLine, FALSE, TRUE) NO-ERROR.
MESSAGE "Create line" SKIP oError VIEW-AS ALERT-BOX.
IF oError <> "" THEN
 DO:
    MESSAGE "Create credit line" SKIP oError VIEW-AS ALERT-BOX.
    RETURN.
 END.  
 
/* auhorize transaction */
/*cTransactionApi:authorizeTransaction(cTrHeader).*/

/**/
/* cTransactionApi:acceptTransaction(). */

/* */

PAUSE.