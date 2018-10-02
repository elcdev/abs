USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

MESSAGE transactionCore:getValidTransactionLine(12, 0).

/*
FOR EACH account /*WHERE gl = 10211000*/:
    DISPLAY account.
    */
    FIND FIRST account NO-LOCK WHERE account.account = "CBLT.EUR".
    DISPLAY account.
    PAUSE.
    
    
    
FOR EACH transaction_line WHERE header_id  = 77:
    DISPLAY transaction_line.id account currency.
END.