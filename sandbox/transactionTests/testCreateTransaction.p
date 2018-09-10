DEFINE VARIABLE cTransactionApi AS transactionApi.
DEFINE VARIABLE cTrDebetLine    AS transactionLineModel.
DEFINE VARIABLE cTrCreditLine   AS transactionLineModel.
DEFINE VARIABLE cTrHeader       AS transactionHeaderModel.

cTransactionApi = NEW transactionApi().

cTrHeader     = cTransactionApi:createHeaderModel().
cTrDebetLine  = cTransactionApi:createLineModel().
cTrCreditLine = cTransactionApi:createLineModel().

