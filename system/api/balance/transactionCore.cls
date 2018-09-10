CLASS transactionCore:
    DEFINE VARIABLE ENABLE-STOP-DEBET-CHECK    AS LOGICAL NO-UNDO INIT YES.
    DEFINE VARIABLE ENABLE-STOP-CREDIT-CHECK   AS LOGICAL NO-UNDO INIT YES.
    
    DEFINE PUBLIC VARIABLE ACCOUNT-STATUS-CLOSED AS CHARACTER INITIAL "closed".
    
    DEFINE VARIABLE currentMenuFunction AS CHARACTER NO-UNDO INITIAL "". /* TODO! */
  
    DEFINE VARIABLE garbage        AS garbageCollectorType.
    
    CONSTRUCTOR transactionCore():
        garbage        = NEW garbageCollectorType().
    END.

    DESTRUCTOR transactionCore():
        DELETE OBJECT garbage        NO-ERROR.
    END.

    METHOD PUBLIC CHARACTER initCore(iCurrentMenuFunction AS CHARACTER):
        currentMenuFunction= iCurrentMenuFunction.
        ENABLE-STOP-DEBET-CHECK  = NO.
        IF getSystemSettingsValue(currentMenuFunction, "NOSDCHECK-FNAME") = "" THEN ENABLE-STOP-DEBET-CHECK  = YES.
        ENABLE-STOP-CREDIT-CHECK = NO.
        IF getSystemSettingsValue(currentMenuFunction, "NOSKCHECK-FNAME") = "" THEN ENABLE-STOP-CREDIT-CHECK = YES.
        
        currentMenuFunction = globalSettings:currentMenuFunction.
        
        RETURN "".
    END.
    
    /* TODO; Move to global settings */    
    METHOD PRIVATE CHARACTER getSystemSettingsValue(iMenuFunctionName AS CHARACTER, iFieldName AS CHARACTER):
        RETURN globalSettings:getValueChar("Balance/MenuDisableCheckStopDC/" + iMenuFunctionName + "/" + iFieldName).
    END.
    
    
    METHOD PUBLIC CHARACTER validateAccountSpecialInstruction(iAccount AS CHARACTER, iInstruction AS CHARACTER):
/*
        DEFINE BUFFER aas FOR aas.
       
        FIND FIRST aas WHERE aas.account = iAccount AND aas.sic = iInstruction NO-LOCK NO-ERROR.
        IF NOT AVAILABLE aas THEN RETURN ""
 */       
        RETURN "ERROR-STOP-DEBET: Stop Debet instruction for " + iAccount +  " ". /* + aas.payee.*/
    END.

    METHOD PUBLIC CHARACTER validateTransactionAccount(iTransactionLine AS transactionLineModel):
        RETURN validateTransactionAccount(iTransactionLine:gl, iTransactionLine:account, iTransactionLine:Currency, iTransactionLine:dc).
    END.
    
    METHOD PUBLIC CHARACTER validateTransactionAccount( iGl                AS INT64,
                                                    iAccount           AS CHARACTER, 
                                                    iCurrency          AS CHARACTER, 
                                                    iDc                AS CHARACTER
                                                    ):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO INITIAL "".
        
        DEFINE BUFFER account FOR account.
        
        FIND FIRST account WHERE account.account = iAccount NO-LOCK NO-ERROR.
        IF NOT AVAILABLE account                          THEN RETURN "ERROR-ACCOUNT-NOT-FOUND".
        IF account.account_status = ACCOUNT-STATUS-CLOSED THEN RETURN "ERROR-ACCOUNT-CLOSED:Account " + iAccount + " is closed!".
        IF account.currency <> iCurrency                  THEN RETURN "ERROR-CURRENCY-NO-MATCH-ACCOUNT:Currency in TRX differs from currency in account " + iAccount + "!".
        
        IF account.gl ne iGl THEN DO:
            RETURN "ERROR-INVALID-GL:Balance account in TRX differs from balance account in account " + iAccount + "!".
        END.
        
        IF INDEX('D,C,', iDc + ',') < 1    THEN RETURN "ERROR-INVALID-DC-VALUE".
        IF iDc = "D" AND ENABLE-STOP-DEBET-CHECK  THEN oError = validateAccountSpecialInstruction(iAccount, "SD").
        IF iDc = "C" AND ENABLE-STOP-CREDIT-CHECK THEN oError = validateAccountSpecialInstruction(iAccount, "SK").
        RETURN oError.
    END. 

    
    METHOD PUBLIC LOG isValidCurrency(iCurrency AS char):
        IF validateCurrency(iCurrency) = "" THEN RETURN TRUE.
        RETURN FALSE.
    END.
    
    METHOD PUBLIC CHARACTER validateCurrency(iCurrency AS char):
        DEFINE BUFFER bf_currency FOR currency.
        
        find bf_currency where bf_currency.currency = iCurrency no-lock no-error.
        IF NOT AVAILABLE bf_currency THEN DO:
            RETURN "ERROR-INVALID-CURRENCY:Currency [" + iCurrency + "] is incorrect!".
        END.
        
        return "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateGlRestricted(iGlAccount AS glAccountModel):
        IF NOT iGlAccount:restrict_operation THEN RETURN "".
        RETURN "ERROR-GL-RESTRICTED:Balance account " + string(iGlAccount:Gl) + " is closed for operations!".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateTrnsactionNumber(iHeaderId AS INT64):
        DEFINE BUFFER transaction_header FOR transaction_header.
        
        FIND FIRST transaction_header WHERE transaction_header.header_id = iHeaderId no-lock no-error.
        IF NOT AVAILABLE transaction_header THEN 
         DO:
            RETURN "ERROR-INCORRECT-HEADER:Incorrect Transaction Number " + string(iHeaderId) + " !".
         END.

         RETURN "".
    END.
    
    METHOD STATIC PUBLIC INT getValidTransactionLine(iHeaderId AS INT64, iLine AS INT):
        DEFINE BUFFER transaction_line FOR transaction_line.
        
        FIND FIRST transaction_line WHERE transaction_line.header_id = iHeaderId 
                                      AND transaction_line.line      = iLine 
                                USE-INDEX header_id 
                                NO-LOCK NO-ERROR.
        
        IF AVAILABLE transaction_line THEN 
         DO:
            FIND LAST transaction_line WHERE transaction_line.header_id = iHeaderId USE-INDEX header_id NO-LOCK NO-ERROR.
            IF AVAILABLE transaction_line THEN iLine = transaction_line.line + 1.
         END.
         
        RETURN iLine.
    END.
 
    METHOD PUBLIC CHARACTER validateBalanceDate(iBalanceDate AS DATE):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
    
        oError = closedDaysApi:validBalanceDate(iBalanceDate).
        IF oError BEGINS closedDaysApi:ERROR-DAY-CLOSED THEN 
         DO:
            IF iBalanceDate = TODAY THEN 
             DO:
                RETURN closedDaysApi:openBalanceDate(iBalanceDate).
             END.
         END.
         
        RETURN oError.
    END.
     
    
    METHOD PUBLIC CHAR getAccountBalance(iGlAccount AS glAccountModel, iAccount AS accountModel, iBalanceDate AS DATE, OUTPUT oBalance AS DEC):
        DEFINE BUFFER account_balance        FOR account_balance.
        DEFINE VARIABLE tOverDraftAccount    AS accountModel NO-UNDO.        
        DEFINE VARIABLE oOdBalance           AS DECIMAL      NO-UNDO.
        DEFINE VARIABLE acc_future_balance   AS DECIMAL      NO-UNDO. 
        DEFINE VARIABLE odacc_future_balance AS DECIMAL      NO-UNDO.
        DEFINE VARIABLE okbal                AS CHARACTER    NO-UNDO.
        DEFINE VARIABLE oError               AS CHARACTER    NO-UNDO.
        
        FIND FIRST account_balance WHERE account_balance.account      = iAccount:account 
                                     AND account_balance.currency     = iAccount:currency
                                     AND account_balance.balance_date = iBalanceDate 
                                 NO-LOCK 
                                NO-ERROR.
                          
        IF NOT AVAILABLE account_balance THEN DO:
            oError = createAccountBalance(iAccount, iBalanceDate).
            IF oError <> "" THEN RETURN oError.
            
            FIND FIRST account_balance WHERE account_balance.account      = iAccount:account 
                                         AND account_balance.balance_date = iBalanceDate 
                                         AND account_balance.currency     = iAccount:currency 
                                     NO-LOCK 
                                     NO-ERROR.
        END.
        
        oBalance = account_balance.balance - account_balance.hold_balance.
        
        IF VALID-OBJECT(iGlAccount) THEN
         DO:
            oError = getFutureAccountBalance(iGlAccount, iAccount, iBalanceDate, OUTPUT acc_future_balance).
            IF oError <> "" THEN RETURN oError.

            oBalance = oBalance + acc_future_balance.
         END.
        
        IF iAccount:overdraft_account = "" THEN RETURN "".
             
        tOverDraftAccount = NEW accountModel().
        garbage:addItem(tOverDraftAccount).
        
        oError = tOverDraftAccount:getDbByAccount(iAccount:overdraft_account).
        IF oError <> "" THEN RETURN oError.
        
        oError = getAccountBalance(?, tOverDraftAccount, iBalanceDate, OUTPUT oOdBalance).
        IF oError <> "" THEN RETURN oError.
        
        oBalance = oBalance + oOdBalance.
        
        RETURN  oError.
    END.


    METHOD PUBLIC CHAR checkTransactionAmount (iTransactionLine AS transactionLineModel, iGlAccount AS glAccountModel, iAccount AS accountModel):
        DEFINE VARIABLE iAccountBalance AS DECIMAL NO-UNDO.
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO. 
        
        oError = getAccountBalance(iGlAccount, iAccount, iTransactionLine:Balance_Date, OUTPUT iAccountBalance). 
        IF oError <> "" THEN RETURN oError.
        
        IF ((iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") AND iTransactionLine:dc = "D") 
           OR 
           ((iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") AND iTransactionLine:dc = "C") THEN 
         DO:
            RETURN "".
         END.
        
        IF ((iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") AND iTransactionLine:dc = "C" AND iAccountBalance GE iTransactionLine:credit) 
           OR
           ((iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") AND iTransactionLine:dc = "D" AND iAccountBalance GE iTransactionLine:debet) THEN 
         DO:
           RETURN "".
         END.  
        
        RETURN "ERROR-OUT-OF-BALANCE:Out of balance on Account " + iTransactionLine:account + "!".
    END.

    METHOD STATIC PUBLIC CHAR createAccountBalance(iAccount AS accountModel, iBalanceDate AS DATE):
        DEFINE BUFFER prev_account_balance FOR account_balance.
        DEFINE BUFFER account_balance      FOR account_balance.
        
        FIND LAST prev_account_balance WHERE prev_account_balance.account      = iAccount:Account 
                                         AND prev_account_balance.currency     = iAccount:Currency 
                                         AND prev_account_balance.balance_date < iBalanceDate 
                              EXCLUSIVE-LOCK NO-ERROR.
        
        CREATE account_balance.
        
        IF AVAILABLE prev_account_balance THEN 
         DO:
            BUFFER-COPY prev_account_balance TO account_balance.
         END.

        ASSIGN 
            account_balance.balance_date = iBalanceDate
            account_balance.account      = iAccount:Account
            account_balance.gl           = iAccount:Gl
            account_balance.currency     = iAccount:Currency.
            /* TODO! Trigger na whn */
        RELEASE prev_account_balance.
        RELEASE account_balance.
        
        RETURN "".
    END.

    METHOD PUBLIC CHAR getFutureAccountBalance(iGlAccount AS glAccountModel, iAccount AS accountModel, iBalanceDate AS DATE, OUTPUT oBalance AS DEC):
        DEFINE BUFFER account_balance_future FOR account_balance_future.
        
        oBalance = 0.
        FOR EACH account_balance_future WHERE account_balance_future.action        = "account_balance" 
                                          AND account_balance_future.account       = iAccount:account
                                          AND account_balance_future.currency      = iAccount:currency 
                                          AND account_balance_future.balance_date <= iBalanceDate NO-LOCK:
            IF iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E" THEN
                oBalance = oBalance + account_balance_future.debet - account_balance_future.credit.
            ELSE IF iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R" THEN 
                oBalance = oBalance + account_balance_future.credit - account_balance_future.debet.
        END.
        
        RETURN "".
    END.
    
    
    METHOD PUBLIC CHAR setAccountLastOperationData (iTransactionLine AS transactionLineModel, iAccount AS accountModel):
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO INITIAL "". 
        
        oError = iAccount:getDb(iAccount:id).
        IF oError <> "" THEN RETURN oError.
    
        IF iTransactionLine:line_type = "D" AND iAccount:last_debet_date < iTransactionLine:balance_date THEN DO:
            iAccount:last_debet_date   = iTransactionLine:balance_date.
            iAccount:last_debet_amount = iTransactionLine:debet.
        END.  
        ELSE IF iTransactionLine:line_type = "C" AND iAccount:last_credit_date < iTransactionLine:balance_date THEN DO:
            iAccount:last_credit_date   = iTransactionLine:balance_date.
            iAccount:last_credit_amount = iTransactionLine:credit.
        END. 
        IF iAccount:last_operation_date < iTransactionLine:balance_date THEN iAccount:last_operation_date = iTransactionLine:balance_date.
        
        RETURN "".
    END.
    
    
    METHOD PUBLIC CHAR createFutureAccountBalance(iTransactionLine AS transactionLineModel, iGlAccount AS glAccountModel):
        DEFINE BUFFER account_balance_future FOR account_balance_future.
        
        create account_balance_future.
        
        assign account_balance_future.action       = "account_balance"
               account_balance_future.header_id    = iTransactionLine:header_id
               account_balance_future.line         = iTransactionLine:line
               account_balance_future.gl           = iTransactionLine:gl
               account_balance_future.currency     = iTransactionLine:currency
               account_balance_future.account      = iTransactionLine:account
               account_balance_future.balance_date = iTransactionLine:balance_date
               account_balance_future.debet        = iTransactionLine:debet
               account_balance_future.credit       = iTransactionLine:credit
               account_balance_future.dc           = iTransactionLine:dc
               account_balance_future.gl_type      = iGlAccount:gl_type
               account_balance_future.create_date  = NOW
               account_balance_future.create_user  = globalSettings:loginName
               account_balance_future.modify_date  = NOW
               account_balance_future.modify_user  = globalSettings:loginName.

        RETURN "".
        
    END.

    METHOD PUBLIC CHAR changeGlBalance(iTransactionLine AS transactionLineModel, iGlAccount AS glAccountModel):
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO INITIAL "". 
        DEFINE BUFFER gl_balance FOR gl_balance.
        
        /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
        FOR EACH gl_balance WHERE gl_balance.gl            = iTransactionLine:gl 
                              AND gl_balance.balance_date >= iTransactionLine:balance_date 
                              AND gl_balance.currency      = iTransactionLine:currency 
                   EXCLUSIVE-LOCK:
            assign
                gl_balance.total_debet  = gl_balance.total_debet + iTransactionLine:debet
                gl_balance.total_credit = gl_balance.total_credit + iTransactionLine:credit.
            
            IF iTransactionLine:dc = "D" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    gl_balance.balance = gl_balance.balance + iTransactionLine:debet.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN
                    gl_balance.balance = gl_balance.balance - iTransactionLine:debet.
             END. 
            ELSE IF iTransactionLine:dc = "C" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    gl_balance.balance = gl_balance.balance - iTransactionLine:credit.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN 
                    gl_balance.balance = gl_balance.balance + iTransactionLine:credit.
             END.        
        END.    

        RETURN oError.
    END.
    
    METHOD PUBLIC CHAR changeAccountBalance(iTransactionLine AS transactionLineModel, iGlAccount AS glAccountModel):
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO INITIAL "". 
        DEFINE BUFFER account_balance FOR account_balance.

        /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
        FOR EACH account_balance WHERE account_balance.account      = iTransactionLine:account 
                                   AND account_balance.balance_date >= iTransactionLine:balance_date 
                                   AND account_balance.currency      = iTransactionLine:currency 
                        EXCLUSIVE-LOCK:
            assign
                account_balance.total_debet  = account_balance.total_debet  + iTransactionLine:debet
                account_balance.total_credit = account_balance.total_credit + iTransactionLine:credit.
            
            IF iTransactionLine:dc = "D" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    account_balance.balance = account_balance.balance + iTransactionLine:debet.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN 
                    account_balance.balance = account_balance.balance - iTransactionLine:debet.
             END. 
            ELSE IF iTransactionLine:dc = "C" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    account_balance.balance = account_balance.balance - iTransactionLine:credit.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R" ) THEN 
                    account_balance.balance = account_balance.balance + iTransactionLine:credit.
             END.        
            account_balance.available_balance = account_balance.balance - account_balance.hold_balance.
        END.    
        
       RETURN "". 
    END.

END.