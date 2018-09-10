/* Main procedure for creating jl */
define input PARAMETER iTransaction  AS transactionLineModel.
define input parameter nocheckbalance      AS LOG. 
define input parameter change_balance_sign AS LOG.

DEFINE VARIABLE cTransationApi AS TransationApi.

cTransationApi = NEW TransationApi().
/*cTransationApi:initCore(g-fname).*/
cTransationApi:create(iTransaction, nocheckbalance, change_balance_sign).
DELETE OBJECT cTransationApi.





 

  
    

