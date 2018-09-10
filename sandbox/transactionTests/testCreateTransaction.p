DEFINE VARIABLE cTransactionApi AS transactionApi.
DEFINE VARIABLE cTrDebetLine    AS transactionLineModel.
DEFINE VARIABLE cTrCreditLine   AS transactionLineModel.
DEFINE VARIABLE cTrHeader       AS transactionHeaderModel.
DEFINE VARIABLE oError          AS CHARACTER.

cTransactionApi = NEW transactionApi().

oError = cTransactionApi:createHeader(cTrHeader).
cTrDebetLine  = cTransactionApi:createLineModel().
cTrCreditLine = cTransactionApi:createLineModel().


