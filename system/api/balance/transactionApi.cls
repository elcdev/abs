CLASS transactionApi:
    DEFINE VARIABLE garbage      AS garbageCollectorType.
    DEFINE VARIABLE cTransactionCore AS transactionCore.
    
    CONSTRUCTOR transactionApi():
        garbage      = NEW garbageCollectorType().
        cTransactionCore = NEW transactionCore().
    END.
    
    DESTRUCTOR transactionApi():
        DELETE OBJECT garbage          NO-ERROR.
        DELETE OBJECT cTransactionCore NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER initCore(iCurrentMenuFunction AS CHARACTER):
        RETURN cTransactionCore:initCore(iCurrentMenuFunction).
    END.
    
    METHOD PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel):
        RETURN createLine(iTransaction, FALSE, FALSE).
    END.
    
    METHOD PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel, nocheckbalance AS LOG, change_balance_sign AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE tAccount   AS accountModel   NO-UNDO.
        DEFINE VARIABLE tGlAccount AS glAccountModel NO-UNDO.
        
        oError = transactionCore:validateTrnsactionNumber(iTransaction:Header_Id).
        IF oError <> "" THEN RETURN oError.
        
        oError = validateLine(iTransaction).
        IF oError <> "" THEN RETURN oError.
        
        tAccount = NEW accountModel().
        oError = tAccount:getDbByAccount(iTransaction:account).
        IF oError <> "" THEN RETURN oError.

        oError = cTransactionCore:ValidateCurrency(iTransaction:currency).
        IF oError <> "" THEN RETURN oError.
        
        tGlAccount = NEW glAccountModel().
        oError = tGlAccount:getDbByGl(tAccount:gl).
        IF oError <> "" THEN RETURN oError.

        oError = transactionCore:validateTrnsactionNumber(iTransaction:header_id).
        IF oError <> "" THEN RETURN oError.

        iTransaction:line = transactionCore:getValidTransactionLine(iTransaction:header_id, iTransaction:line).

        oError = transactionCore:validateGlRestricted(tGlAccount).
        IF oError <> "" THEN RETURN oError.
        
        oError = cTransactionCore:validateGlBalance(iTransaction, tGlAccount).
        IF oError <> "" THEN change_balance_sign = NO.

        do transaction :
            find FIRST currency where currency.currency = iTransaction:currency no-lock no-error.
            if available currency then do :
                iTransaction:debet  = round(iTransaction:debet,  currency.decimal_points).
                iTransaction:credit = round(iTransaction:credit, currency.decimal_points).
            end.
                
            oError = cTransactionCore:validateBalanceDate(iTransaction:balance_date).
            IF oError <> "" THEN UNDO, RETURN oError.
            
            iTransaction:cif = tAccount:cif.
            
            IF tGlAccount:subledger_type NE "" THEN DO:
                oError = cTransactionCore:validateTransactionAccount(iTransaction). 
                IF oError <> "" THEN RETURN oError.

                IF nocheckbalance = NO THEN 
                 DO:
                    oError = cTransactionCore:checkTransactionAmount(iTransaction, tGlAccount, tAccount).
                    IF oError <> "" THEN RETURN oError.
                 END.
                
                oError = iTransaction:putDb().
                IF oError <> "" THEN RETURN oError.
               
                /* ьФП РТЙЪОБЛ ФПЗП, ЮФП ОБДП ОБЛБФЩЧБФШ ПУФБФПЛ УТБЪХ */
                IF change_balance_sign = YES THEN DO:
                    oError = cTransactionCore:changeGlBalance(iTransaction, tGlAccount).
                    IF oError <> "" THEN RETURN oError.
                    
                    oError = cTransactionCore:changeAccountBalance(iTransaction, tGlAccount).
                    IF oError <> "" THEN RETURN oError.
                    
                    oError = cTransactionCore:setAccountLastOperationData(iTransaction, tAccount).
                END.
                ELSE DO:
                    oError = cTransactionCore:createFutureAccountBalance(iTransaction, tGlAccount).
                END.  
            END.
            ELSE DO:
                IF change_balance_sign = YES THEN 
                    oError = cTransactionCore:changeGlBalance(iTransaction, tGlAccount).
                ELSE
                 DO:
                    oError = cTransactionCore:createFutureAccountBalance(iTransaction, tGlAccount).
                 END.
                
            END.
            RETURN oError.
        end.

        RETURN "".
    END.

    METHOD PUBLIC transactionLineModel createLineModel():
        DEFINE VARIABLE iTransactionLine AS transactionLineModel.
        
        iTransactionLine = NEW transactionLineModel().
        garbage:addItem(iTransactionLine).
        
        RETURN iTransactionLine.
    END.
    
    METHOD PUBLIC transactionHeaderModel createHeaderModel():
        DEFINE VARIABLE iTransactionHeader AS transactionHeaderModel.
        
        iTransactionHeader = NEW transactionHeaderModel().
        garbage:addItem(iTransactionHeader).
        
        RETURN iTransactionHeader.
    END.
    
    METHOD PUBLIC CHAR createHeader(iTransactionHeader AS transactionHeaderModel):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        IF NOT VALID-OBJECT(iTransactionHeader) THEN
         DO:
            iTransactionHeader = createHeaderModel().
         END.
        
        oError = iTransactionHeader:putDb().
        
        RETURN oError.
    END.
    
    METHOD PUBLIC CHAR validateLine(iTransactionLine AS transactionLineModel):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = cTransactionCore:validateTransactionAccount(iTransactionLine).
        
        /* TODO VALIDATE */
        
        RETURN oError.
    END.
    
    METHOD PUBLIC CHARACTER authorizeTransaction(iTransactionHeader AS transactionHeaderModel):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        DEFINE BUFFER transaction_line FOR transaction_line.
        
        IF NOT VALID-OBJECT(iTransactionHeader) THEN RETURN "ERROR-HEADER-UNDEFINED".
        
        DO TRANSACTION:
            FOR EACH transaction_line:
                transaction_line.authorize_user = globalSettings:loginName.
                transaction_line.authorize_date = today.
            END.
            
            iTransactionHeader:authorize_user = globalSettings:loginName.
            iTransactionHeader:authorize_date = today.
            oError = iTransactionHeader:putDb().
            IF oError <> "" THEN UNDO.
        END. 
        
        RETURN oError.
    END.
    
END.