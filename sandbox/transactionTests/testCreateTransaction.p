USING system.api.payments.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.

DEFINE VARIABLE cTrDebetLine    AS transactionLineModel.
DEFINE VARIABLE cTrCreditLine   AS transactionLineModel.
DEFINE VARIABLE cTrHeader       AS transactionHeaderModel.
DEFINE VARIABLE tDetails        AS CHARACTER NO-UNDO.
DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.

RUN startupSettings.p. 


DO TRANSACTION ON ERROR UNDO, THROW:
    oError = transactionApi:createHeader(INPUT-OUTPUT cTrHeader).
    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-HEADER", 1).

    cTrDebetLine  = transactionApi:createLineModel(cTrHeader).
    cTrCreditLine = transactionApi:createLineModel(cTrHeader).

    tDetails = "Test transaction for date %balnce_date%".

    oError = cTrDebetLine:setLineData("A100000", "D", 1000, "EUR", tDetails).
    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-DEBET-DATA", 1).

    oError = cTrCreditLine:setLineData("A200000", "C", 1000, "EUR", tDetails).
    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).
     
    oError = transactionApi:createLine(cTrDebetLine, FALSE, TRUE).
    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-DEBET", 1).

    oError = transactionApi:createLine(cTrCreditLine, FALSE, TRUE) NO-ERROR.
    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-CREDIT", 1).
    
    CATCH eAnyError AS Progress.Lang.Error:
        MESSAGE "ERROR TUT " SKIP eAnyError:GetMessage(1) VIEW-AS ALERT-BOX.
    END CATCH.
    
    FINALLY:
        MESSAGE "Transaction made successfully!" SKIP "header_id:" cTrHeader:header_id VIEW-AS ALERT-BOX.
    END.
END.


