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
        RETURN TransactionCore:initCore(iCurrentMenuFunction).
    END.
    
    METHOD PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel):
        RETURN createLine(iTransaction, FALSE, FALSE).
    END.
    
    METHOD PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel, nocheckbalance AS LOG, change_balance_sign AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE tAccount   AS accountModel   NO-UNDO.
        DEFINE VARIABLE tGlAccount AS glAccountModel NO-UNDO.
        
        DO ON ERROR UNDO, THROW:
            oError = transactionCore:validateTrnsactionNumber(iTransaction:Header_Id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 400).
            
            oError = validateLine(iTransaction).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 401).
            
            tAccount = iTransaction:getAccount.
            oError = tAccount:getDbByAccount(iTransaction:account). /* TODO! Rewrite */
            
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 402).

            oError = TransactionCore:ValidateCurrency(iTransaction:currency).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 403).

            tGlAccount = iTransaction:getGlAccount.
            oError = tGlAccount:getDbByGl(tAccount:gl).
            IF oError <> "" THEN 
             DO:
                oError = "ERROR-GL-" + oError.
                UNDO, THROW NEW Progress.Lang.AppError(oError, 404).
             END.

            oError = transactionCore:validateTrnsactionNumber(iTransaction:header_id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 405).

            iTransaction:line = transactionCore:getValidTransactionLine(iTransaction:header_id, iTransaction:line).

            oError = transactionCore:validateGlRestricted(tGlAccount).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 406).
            
            oError = transactionCore:validateGlBalance(iTransaction).
            IF oError <> "" THEN change_balance_sign = NO.

            oError = transactionCore:validateBalanceDate(iTransaction:balance_date).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 500).

            DO TRANSACTION ON ERROR UNDO, THROW:
                find FIRST currency where currency.currency = iTransaction:currency no-lock no-error.
                if available currency then do :
                    iTransaction:debet  = round(iTransaction:debet,  currency.decimal_points).
                    iTransaction:credit = round(iTransaction:credit, currency.decimal_points).
                end.

                iTransaction:cif = tAccount:cif.
                
                IF tGlAccount:subledger_type NE "" THEN DO:
                    oError = TransactionCore:validateTransactionAccount(iTransaction). 
                    IF oError <> "" THEN RETURN oError.

                    IF nocheckbalance = NO THEN 
                     DO:
                        oError = TransactionCore:checkTransactionAmount(iTransaction).
                        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 501).
                     END.

                     oError = iTransaction:putDb().
                    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 502).

                    /* ьФП РТЙЪОБЛ ФПЗП, ЮФП ОБДП ОБЛБФЩЧБФШ ПУФБФПЛ УТБЪХ */
                    IF change_balance_sign = YES THEN DO:
                        oError = transactionCore:changeGlBalance(iTransaction).
                        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 503).

                        oError = transactionCore:changeAccountBalance(iTransaction).
                        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 504).

                        oError = transactionCore:setAccountLastOperationData(iTransaction).
                    END.
                    ELSE DO:
                        oError = transactionCore:createFutureAccountBalance(iTransaction).
                    END.  
                END.
                ELSE DO:
                    IF change_balance_sign = YES THEN 
                        oError = transactionCore:changeGlBalance(iTransaction).
                    ELSE
                     DO:
                        oError = transactionCore:createFutureAccountBalance(iTransaction).
                     END.
                END.
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 505).
            END.
            RETURN oError.
        END.
        
        CATCH eAnyError AS Progress.Lang.Error:
            /*oError =  oError + ":" + eAnyError:GetMessage(1).*/
        END CATCH.

        FINALLY:
            RETURN oError.
        END.
    END.

    METHOD PUBLIC transactionLineModel createLineModel(iTransactionHeader AS transactionHeaderModel):
        DEFINE VARIABLE iTransactionLine AS transactionLineModel.
        
        iTransactionLine = NEW transactionLineModel(iTransactionHeader).
        garbage:addItem(iTransactionLine).
        
        iTransactionLine:header_id    = iTransactionHeader:header_id.
        iTransactionLine:balance_date = iTransactionHeader:balance_date.
        
        RETURN iTransactionLine.
    END.
    
    METHOD PUBLIC transactionHeaderModel createHeaderModel():
        DEFINE VARIABLE iTransactionHeader AS transactionHeaderModel.
        
        iTransactionHeader = NEW transactionHeaderModel().
        garbage:addItem(iTransactionHeader).
        iTransactionHeader:initDefaultSettings().
        
        RETURN iTransactionHeader.
    END.
    
    METHOD PUBLIC CHAR createHeader(INPUT-OUTPUT iTransactionHeader AS transactionHeaderModel):
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
        
        oError = TransactionCore:validateTransactionAccount(iTransactionLine).
        
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