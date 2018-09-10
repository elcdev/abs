CLASS transactionApi:
    DEFINE VARIABLE garbage      AS garbageCollectorType.
    DEFINE VARIABLE cTransactionCore AS transactionCore.
    
    CONSTRUCTOR transactionApi():
        garbage      = NEW garbageCollectorType().
        cTransactionCore = NEW transactionCore().
    END.
    
    DESTRUCTOR transactionApi():
        DELETE OBJECT garbage     NO-ERROR.
        DELETE OBJECT cTransactionCore NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER initCore(iCurrentMenuFunction AS CHARACTER):
        RETURN cTransactionCore:initCore(iCurrentMenuFunction).
    END.
    
    METHOD PUBLIC CHARACTER create(iTransaction AS transactionLineModel, nocheckbalance AS LOG, change_balance_sign AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE tAccount   AS accountModel   NO-UNDO.
        DEFINE VARIABLE tGlAccount AS glAccountModel NO-UNDO.
        
        oError = validate(iTransaction).
        IF oError <> "" THEN RETURN oError.
        
        tAccount = NEW accountModel().
        oError = tAccount:getDbByAccount(iTransaction:account).
        IF oError <> "" THEN RETURN oError.

        tGlAccount = NEW glAccountModel().
        oError = tGlAccount:getDbByGl(tAccount:gl).
        IF oError <> "" THEN RETURN oError.

        oError = transactionCore:validateTrnsactionNumber(iTransaction:header_id).
        IF oError <> "" THEN RETURN oError.

        iTransaction:line = transactionCore:getValidTransactionLine(iTransaction:header_id, iTransaction:line).

        oError = transactionCore:validateGlRestricted(tGlAccount).
        IF oError <> "" THEN RETURN oError.

        oError = cTransactionCore:ValidateCurrency(iTransaction:currency).
        IF oError <> "" THEN RETURN oError.



        do transaction :
            find FIRST currency where currency.currency = iTransaction:currency no-lock no-error.
            if available currency then do :
                iTransaction:debet = round(iTransaction:debet,currency.decimal_points).
                iTransaction:credit = round(iTransaction:credit,currency.decimal_points).
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
        DEFINE VARIABLE iTransaction AS transactionLineModel.
        
        iTransaction = NEW transactionLineModel().
        garbage:addItem(iTransaction).
        
        RETURN iTransaction.
    END.
    
    METHOD PUBLIC transactionHeaderModel createHeaderModel():
        DEFINE VARIABLE iTransaction AS transactionHeaderModel.
        
        iTransaction = NEW transactionHeaderModel().
        garbage:addItem(iTransaction).
        
        RETURN iTransaction.
    END.
    
    METHOD PUBLIC CHAR validate(iTransaction AS transactionLineModel):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = cTransactionCore:validateTransactionAccount(iTransaction).
        
        /* TODO VALIDATE */
        
        RETURN oError.
    END.
    
    
END.