USING system.api.systemSettings.*.
USING system.api.balance.*.

CLASS system.api.balance.transactionCore:
    DEFINE STATIC VARIABLE ENABLE-STOP-DEBET-CHECK    AS LOGICAL NO-UNDO INIT YES.
    DEFINE STATIC VARIABLE ENABLE-STOP-CREDIT-CHECK   AS LOGICAL NO-UNDO INIT YES.
    
    DEFINE STATIC PUBLIC VARIABLE ACCOUNT-STATUS-CLOSED AS CHARACTER INITIAL "closed".
    
    DEFINE STATIC VARIABLE currentMenuFunction AS CHARACTER NO-UNDO INITIAL "". /* TODO! */
  
    DEFINE STATIC VARIABLE garbage        AS garbageCollectorType.
    
    CONSTRUCTOR transactionCore():
        garbage        = NEW garbageCollectorType().
    END.

    DESTRUCTOR transactionCore():
        DELETE OBJECT garbage        NO-ERROR.
    END.

    METHOD STATIC PUBLIC CHARACTER initCore(iCurrentMenuFunction AS CHARACTER):
        currentMenuFunction= iCurrentMenuFunction.
        ENABLE-STOP-DEBET-CHECK  = NO.
        IF getSystemSettingsValue(currentMenuFunction, "NOSDCHECK-FNAME") = "" THEN ENABLE-STOP-DEBET-CHECK  = YES.
        ENABLE-STOP-CREDIT-CHECK = NO.
        IF getSystemSettingsValue(currentMenuFunction, "NOSKCHECK-FNAME") = "" THEN ENABLE-STOP-CREDIT-CHECK = YES.
        
        currentMenuFunction = globalSettings:currentMenuFunction.
        
        RETURN "".
    END.
    
    /* TODO; Move to global settings */    
    METHOD STATIC PRIVATE CHARACTER getSystemSettingsValue(iMenuFunctionName AS CHARACTER, iFieldName AS CHARACTER):
        RETURN globalSettings:getValueChar("Balance/MenuDisableCheckStopDC/" + iMenuFunctionName + "/" + iFieldName).
    END.
    
    
    METHOD STATIC PUBLIC CHARACTER validateAccountSpecialInstruction(iAccount AS CHARACTER, iInstruction AS CHARACTER):
        DEFINE BUFFER account_restrictions FOR account_restrictions.
       
        FIND FIRST account_restrictions WHERE account_restrictions.account     = iAccount 
                                          AND account_restrictions.instruction = iInstruction 
                                          NO-LOCK NO-ERROR.
        IF NOT AVAILABLE account_restrictions THEN RETURN "".
 
        RETURN "ERROR-STOP-DEBET: Stop Debet instruction for " + iAccount +  " ". /* + aas.payee.*/
    END.

    METHOD STATIC PUBLIC CHARACTER validateTransactionAccount(iTransactionLine AS transactionLineModel):
        RETURN validateTransactionAccount(iTransactionLine:gl, iTransactionLine:account, iTransactionLine:Currency, iTransactionLine:dc).
    END.
    
    /* TODO!!! */
    METHOD STATIC PUBLIC CHARACTER validateTransactionAccount( iGl                AS INT64,
                                                        iAccount           AS CHARACTER, 
                                                        iCurrency          AS CHARACTER, 
                                                        iDc                AS CHARACTER
                                                      ):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO INITIAL "".
        
        DEFINE BUFFER account FOR account.
        
        IF iAccount <> "" THEN
         DO:
            FIND FIRST account WHERE account.account = iAccount NO-LOCK NO-ERROR.
            IF NOT AVAILABLE account                          THEN RETURN "ERROR-ACCOUNT-NOT-FOUND".
            IF account.account_status = ACCOUNT-STATUS-CLOSED THEN RETURN "ERROR-ACCOUNT-CLOSED:Account " + iAccount + " is closed!".
            IF account.currency <> iCurrency                  THEN RETURN "ERROR-CURRENCY-NO-MATCH-ACCOUNT:Currency in TRX differs from currency in account " + iAccount + "!".
        
            IF account.gl ne iGl THEN DO:
                RETURN "ERROR-INVALID-GL:Balance account in TRX differs from balance account in account " + iAccount + "!".
            END.
         END.
        ELSE
         DO:
            oError = validateGl(iGl).
            IF oError <> "" THEN RETURN oError.
         END.

        oError = validateDc(iDC).
        IF oError <> "" THEN RETURN oError.
        
        IF iDc = "D" AND ENABLE-STOP-DEBET-CHECK  THEN oError = validateAccountSpecialInstruction(iAccount, "SD").
        IF iDc = "C" AND ENABLE-STOP-CREDIT-CHECK THEN oError = validateAccountSpecialInstruction(iAccount, "SK").
        RETURN oError.
    END. 

    
    METHOD STATIC PUBLIC CHAR  validateGl(iGl AS INT64):
        DEFINE BUFFER gl FOR gl.
        
        FIND gl WHERE gl.gl = iGl NO-LOCK NO-ERROR.
        IF NOT AVAILABLE gl THEN 
         DO:
            RETURN "ERROR-INVALID-GL;Balance account " + string(iGl, ">>>>>9") +  " is incorrect!".
         END.

        RETURN "".
    END.
 
 
    METHOD STATIC PUBLIC CHARACTER validateDc(iDC AS CHAR):
        IF INDEX("D,C, ", iDC + ",") < 1 THEN RETURN "ERROR-INVALID-DC-VALUE".
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC LOG isValidCurrency(iCurrency AS char):
        IF validateCurrency(iCurrency) = "" THEN RETURN TRUE.
        RETURN FALSE.
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateCurrency(iCurrency AS char):
        DEFINE BUFFER bf_currency FOR currency.
        
        find bf_currency where bf_currency.currency = iCurrency no-lock no-error.
        IF NOT AVAILABLE bf_currency THEN DO:
            RETURN "ERROR-INVALID-CURRENCY:Currency [" + iCurrency + "] is incorrect!".
        END.
        
        return "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateGlRestricted(iGlAccount AS glModel):
        IF NOT iGlAccount:restrict_operation THEN RETURN "".
        RETURN "ERROR-GL-RESTRICTED:Balance account " + string(iGlAccount:Gl) + " is closed for operations!".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateTransactionNumber(iHeaderId AS INT64):
        DEFINE BUFFER transaction_header FOR transaction_header.
        
        FIND FIRST transaction_header WHERE transaction_header.header_id = iHeaderId 
        AND transaction_header.state <> 9 no-lock no-error.
        IF NOT AVAILABLE transaction_header THEN 
         DO:
            RETURN "ERROR-INCORRECT-HEADER:Incorrect Transaction Number " + string(iHeaderId) + " !".
         END.

         RETURN "".
    END.
    METHOD STATIC PUBLIC CHARACTER validateTransactionNumberLine(iHeaderId AS INT64, iLine AS INT):
        DEFINE BUFFER transaction_line FOR transaction_line.
         
        FIND FIRST transaction_line WHERE transaction_line.header_id = iHeaderId 
                                      AND transaction_line.line      = iLine 
                                      AND transaction_line.state     <> 9
                                      USE-INDEX header_id 
                                      NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE transaction_line THEN 
         DO:
            RETURN "ERROR-INCORRECT-TRX-LINE:Incorrect Transaction Line " + string(iHeaderId) + 
            " " + STRING(iLine) +  " !".
         END.
        
         RETURN "".
    END.
    
    METHOD STATIC PUBLIC INT getValidTransactionLine(iHeaderId AS INT64, iLine AS INT):
        DEFINE BUFFER transaction_line FOR transaction_line.
        
        FIND FIRST transaction_line WHERE transaction_line.header_id = iHeaderId 
                                      AND transaction_line.line      = iLine 
                                      AND transaction_line.state     <> 9
                                USE-INDEX header_id 
                                NO-LOCK NO-ERROR.
        
        IF AVAILABLE transaction_line THEN 
         DO:
            FIND LAST transaction_line WHERE transaction_line.header_id = iHeaderId 
            AND transaction_line.state <> 9 USE-INDEX header_id NO-LOCK NO-ERROR.
            IF AVAILABLE transaction_line THEN iLine = transaction_line.line + 1.
         END.
         
        RETURN iLine.
    END.
 
    METHOD STATIC PUBLIC CHARACTER validateBalanceDate(iBalanceDate AS DATE):
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
     
    
    METHOD STATIC PUBLIC CHAR getAccountBalance(iGlAccount AS glModel, iAccount AS accountModel, iBalanceDate AS DATE, OUTPUT oBalance AS DEC):
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

    METHOD STATIC PUBLIC CHAR checkTransactionAmount (iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE iAccountBalance AS DECIMAL        NO-UNDO.
        DEFINE VARIABLE oError          AS CHARACTER      NO-UNDO. 
        DEFINE VARIABLE iGlAccount      AS glModel NO-UNDO.
        DEFINE VARIABLE iAccount        AS accountModel   NO-UNDO.
        
        iGlAccount = iTransactionLine:getGlAccount.
        iAccount   = iTransactionLine:getAccount.
        
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
            BUFFER-COPY prev_account_balance EXCEPT balance_date id version TO account_balance.
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

    METHOD STATIC PUBLIC CHAR getFutureAccountBalance(iGlAccount AS glModel, iAccount AS accountModel, iBalanceDate AS DATE, OUTPUT oBalance AS DEC):
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
    
    
    METHOD STATIC PUBLIC CHAR setAccountLastOperationData (iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError   AS CHARACTER    NO-UNDO INITIAL "". 
        DEFINE VARIABLE iAccount AS accountModel NO-UNDO.
        
        iAccount = iTransactionLine:getAccount.
        
        oError = iAccount:getDb(iAccount:id).
        IF oError <> "" THEN RETURN oError.
    
        IF iTransactionLine:line_type = "D" AND (iAccount:last_debet_date < iTransactionLine:balance_date OR iAccount:last_debet_date = ?) THEN 
         DO:
            iAccount:last_debet_date   = iTransactionLine:balance_date.
            iAccount:last_debet_amount = iTransactionLine:debet.
         END.  
        ELSE IF iTransactionLine:line_type = "C" AND (iAccount:last_credit_date < iTransactionLine:balance_date OR iAccount:last_credit_date = ?) THEN 
         DO:
            iAccount:last_credit_date   = iTransactionLine:balance_date.
            iAccount:last_credit_amount = iTransactionLine:credit.
         END.
         
        IF iAccount:last_operation_date < iTransactionLine:balance_date OR iAccount:last_operation_date = ? THEN 
         DO:
            iAccount:last_operation_date = iTransactionLine:balance_date.
         END.
        
        RETURN iAccount:putDb().
    END.
    
    
    METHOD STATIC PUBLIC CHAR createFutureAccountBalance(iTransactionLine AS transactionLineModel):
        DEFINE BUFFER account_balance_future FOR account_balance_future.
        DEFINE VARIABLE iGlAccount AS glModel NO-UNDO.
        
        iGlAccount = iTransactionLine:getGlAccount.
        
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

    METHOD STATIC PUBLIC CHAR changeGlBalance(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO INITIAL "". 
        DEFINE VARIABLE iGlAccount AS glModel NO-UNDO.
        
        DEFINE BUFFER gl_balance FOR gl_balance.
        
        iGlAccount = iTransactionLine:GetGlAccount.
        
        /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
        FOR EACH gl_balance WHERE gl_balance.gl            = iTransactionLine:gl 
                              AND gl_balance.balance_date >= iTransactionLine:balance_date 
                              AND gl_balance.currency      = iTransactionLine:currency 
                   EXCLUSIVE-LOCK:
            ASSIGN 
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
    
    METHOD STATIC PUBLIC CHARACTER changeAccountBalance(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError          AS CHARACTER      NO-UNDO INITIAL "".
        DEFINE VARIABLE iGlAccount      AS glModel NO-UNDO.        
        
        DEFINE BUFFER account_balance FOR account_balance.

        iGlAccount = iTransactionLine:GetGlAccount.
        
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

    METHOD STATIC PUBLIC CHARACTER validateGlBalance (iTransactionLine AS transactionLineModel):
        DEFINE BUFFER gl_balance FOR gl_balance.
        DEFINE VARIABLE iGlAccount      AS glModel NO-UNDO.   
        
        iGlAccount = iTransactionLine:GetGlAccount.
        
        FIND FIRST gl_balance WHERE gl_balance.gl           = iGlAccount:gl
                                AND gl_balance.balance_date = iTransactionLine:balance_date
                                AND gl_balance.currency     = iTransactionLine:currency 
                                NO-LOCK NO-ERROR.

        IF AVAILABLE gl_balance THEN RETURN "".
        
        RETURN "ERROR-NO-GL-BALANCE".
    END. 
    
    METHOD STATIC PUBLIC CHARACTER validateAccount(iAccount AS CHARACTER):
        DEFINE BUFFER account FOR account.
        
        IF NOT CAN-FIND(FIRST account NO-LOCK WHERE account.account = iAccount) THEN RETURN "ERROR-INVALID-ACCOUNT".
        
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHAR checkTransactionAmountForDelete (iTransactionLine AS transactionLineModel, forced_key AS LOG):
        DEFINE VARIABLE iAccountBalance AS DECIMAL        NO-UNDO.
        DEFINE VARIABLE oError          AS CHARACTER      NO-UNDO. 
        DEFINE VARIABLE iGlAccount      AS glModel NO-UNDO.
        DEFINE VARIABLE iAccount        AS accountModel   NO-UNDO.
        
        iGlAccount = iTransactionLine:getGlAccount.
        iAccount   = iTransactionLine:getAccount.
        
        IF forced_key = YES THEN DO:
            RETURN "".   
        END.
        oError = getAccountBalance(iGlAccount, iAccount, iTransactionLine:Balance_Date, OUTPUT iAccountBalance). 
        IF oError <> "" THEN RETURN oError.
        
        IF ((iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") AND iTransactionLine:dc = "C") 
           OR 
           ((iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") AND iTransactionLine:dc = "D") THEN 
         DO:
            RETURN "".
         END.
        
        IF ((iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") AND iTransactionLine:dc = "D" AND iAccountBalance GE iTransactionLine:credit) 
           OR
           ((iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") AND iTransactionLine:dc = "C" AND iAccountBalance GE iTransactionLine:debet) THEN 
         DO:
           RETURN "".
         END.  
        
        RETURN "ERROR-OUT-OF-BALANCE:Can't delete - Out of balance on Account " + iTransactionLine:account + "!".
    END.
    
    METHOD STATIC PUBLIC CHARACTER changeAccountBalanceForDelete(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError          AS CHARACTER      NO-UNDO INITIAL "".
        DEFINE VARIABLE iGlAccount      AS glModel NO-UNDO.        
        
        DEFINE BUFFER account_balance FOR account_balance.

        iGlAccount = iTransactionLine:GetGlAccount.
        
        /* Otkat ostatka ot dati operaciji do poslednej otkritoj dati */
        FOR EACH account_balance WHERE account_balance.account      = iTransactionLine:account 
                                   AND account_balance.balance_date >= iTransactionLine:balance_date 
                                   AND account_balance.currency      = iTransactionLine:currency 
                        EXCLUSIVE-LOCK:
            

            assign
                account_balance.total_debet  = account_balance.total_debet  - iTransactionLine:debet
                account_balance.total_credit = account_balance.total_credit - iTransactionLine:credit.
          
            IF iTransactionLine:dc = "D" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    account_balance.balance = account_balance.balance - iTransactionLine:debet.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN 
                    account_balance.balance = account_balance.balance + iTransactionLine:debet.
             END. 
            ELSE IF iTransactionLine:dc = "C" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    account_balance.balance = account_balance.balance + iTransactionLine:credit.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R" ) THEN 
                    account_balance.balance = account_balance.balance - iTransactionLine:credit.
             END.        
            account_balance.available_balance = account_balance.balance - account_balance.hold_balance.
        END.    
        
       RETURN "". 
    END.
    
    METHOD STATIC PUBLIC CHAR changeGlBalanceForDelete(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO INITIAL "". 
        DEFINE VARIABLE iGlAccount AS glModel NO-UNDO.
        
        DEFINE BUFFER gl_balance FOR gl_balance.
        
        iGlAccount = iTransactionLine:GetGlAccount.
        
        /* Otkat ostatka ot dati operaciji do poslednej otkritoj dati */
        FOR EACH gl_balance WHERE gl_balance.gl            = iTransactionLine:gl 
                              AND gl_balance.balance_date >= iTransactionLine:balance_date 
                              AND gl_balance.currency      = iTransactionLine:currency 
                   EXCLUSIVE-LOCK:
            ASSIGN 
                gl_balance.total_debet  = gl_balance.total_debet - iTransactionLine:debet
                gl_balance.total_credit = gl_balance.total_credit - iTransactionLine:credit.
            
            IF iTransactionLine:dc = "D" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    gl_balance.balance = gl_balance.balance - iTransactionLine:debet.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN
                    gl_balance.balance = gl_balance.balance + iTransactionLine:debet.
             END. 
            ELSE IF iTransactionLine:dc = "C" THEN 
             DO:
                IF (iGlAccount:gl_type = "A" OR iGlAccount:gl_type = "E") THEN 
                    gl_balance.balance = gl_balance.balance + iTransactionLine:credit.
                ELSE IF (iGlAccount:gl_type = "L" OR iGlAccount:gl_type = "O" OR iGlAccount:gl_type = "R") THEN 
                    gl_balance.balance = gl_balance.balance - iTransactionLine:credit.
             END.        
        END.    

        RETURN oError.
    END.
    
    METHOD STATIC PUBLIC CHAR deleteFutureAccountBalance(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO INITIAL "".
        DEFINE BUFFER account_balance_future FOR account_balance_future.
        
        FIND FIRST account_balance_future WHERE account_balance_future.header_id = iTransactionLine:header_id 
                                            AND account_balance_future.line = iTransactionLine:line 
                                 EXCLUSIVE-LOCK 
                                 NO-ERROR.
        IF AVAILABLE account_balance_future THEN 
         DO:
            DELETE account_balance_future.
         END.
        ELSE 
         DO:
            oError = "CAN'T DELETE FUTURE BALANCE".
         END.
         
        RETURN oError.
    END.
    
    METHOD STATIC PUBLIC LOG isFutureBalanceForLine(iTransactionLine AS transactionLineModel):
        DEFINE BUFFER account_balance_future FOR account_balance_future.
        
        FIND FIRST account_balance_future WHERE account_balance_future.header_id = iTransactionLine:header_id 
                                            AND account_balance_future.line = iTransactionLine:line 
                                        NO-LOCK 
                                        NO-ERROR.
        IF AVAILABLE account_balance_future THEN RETURN YES.
        RETURN NO.
    END. 
    
    METHOD STATIC PUBLIC CHAR setDeletedStatus(iTransactionLine AS transactionLineModel,delete_header AS LOG):
        DEFINE BUFFER transaction_line FOR transaction_line. 
        DEFINE BUFFER transaction_header FOR transaction_line.
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO INITIAL "".
        
        FIND FIRST transaction_line WHERE transaction_line.header_id = iTransactionLine:Header_Id 
                                      AND transaction_line.line      = iTransactionLine:Line 
                                      AND transaction_line.state <> 9 
                                USE-INDEX header_id 
                                EXCLUSIVE-LOCK 
                                NO-ERROR.
        IF AVAILABLE transaction_line THEN 
         DO:
            ASSIGN
                transaction_line.state = 9.
            IF delete_header = YES THEN DO:
                FIND FIRST transaction_line WHERE transaction_line.header_id = iTransactionLine:Header_Id 
                       AND transaction_line.state <> 9 USE-INDEX header_id NO-LOCK NO-ERROR.
                IF NOT AVAILABLE transaction_line THEN DO:
                    FIND FIRST transaction_header WHERE transaction_header.header_id = iTransactionLine:Header_Id 
                    USE-INDEX header_id  EXCLUSIVE-LOCK NO-ERROR.
                    IF AVAILABLE transaction_header THEN 
                    ASSIGN
                        transaction_header.state = 9.
                END.
            END.    
                 
         END.
        ELSE 
         DO:
            oError = "CAN'T SET DELETED STATUS".
         END.
         
        RETURN oError.
    END.
END.    