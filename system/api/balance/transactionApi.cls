USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

CLASS system.api.balance.transactionApi:
    DEFINE STATIC VARIABLE garbage      AS garbageCollectorType.
    
    CONSTRUCTOR transactionApi():
        garbage      = NEW garbageCollectorType().
        TransactionCore:initCore("").
    END.
    
    DESTRUCTOR transactionApi():
        DELETE OBJECT garbage          NO-ERROR.
    END.
    
    METHOD STATIC PUBLIC CHARACTER initCore(iCurrentMenuFunction AS CHARACTER):
        IF NOT VALID-OBJECT (garbage) THEN
         DO:
            garbage      = NEW garbageCollectorType().
            RETURN TransactionCore:initCore(iCurrentMenuFunction).
         END.
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel):
        RETURN createLine(iTransaction, FALSE, TRUE).
    END.
    
    METHOD STATIC PUBLIC CHARACTER createLine(iTransaction AS transactionLineModel, nocheckbalance AS LOG, change_balance_sign AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE tAccount   AS accountModel   NO-UNDO.
        DEFINE VARIABLE tGlAccount AS glModel NO-UNDO.
        DEFINE BUFFER currency     FOR currency.
        
        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = transactionCore:validateTransactionNumber(iTransaction:Header_Id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 400).

            oError = validateLine(iTransaction).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 401).

            oError = TransactionCore:ValidateCurrency(iTransaction:currency).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 403).

            /*TODO Move this validation to model */
            tGlAccount = iTransaction:getGlAccount.
            oError = tGlAccount:getDbByGl(iTransaction:gl).

            IF oError <> "" THEN 
             DO:
                oError = "ERROR-GL-" + oError.
                UNDO, THROW NEW Progress.Lang.AppError(oError, 404).
             END.


            iTransaction:line = transactionCore:getValidTransactionLine(iTransaction:header_id, iTransaction:line).

            oError = transactionCore:validateGlRestricted(tGlAccount).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 406).

            oError = transactionCore:validateGlBalance(iTransaction).
            IF oError <> "" THEN change_balance_sign = NO.

            oError = transactionCore:validateBalanceDate(iTransaction:balance_date).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 500).

            
            FIND FIRST currency WHERE currency.currency = iTransaction:currency NO-LOCK NO-ERROR.
            if available currency then do :
                iTransaction:debet  = round(iTransaction:debet,  currency.decimal_points).
                iTransaction:credit = round(iTransaction:credit, currency.decimal_points).
                
            end.

           
            IF tGlAccount:subledger_type NE "" THEN DO:
                tAccount = iTransaction:getAccount.
                oError = tAccount:getDbByAccount(iTransaction:account). /* TODO! Rewrite */
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 402).
                iTransaction:cif = tAccount:cif.    
                
                oError = TransactionCore:validateTransactionAccount(iTransaction). 
                IF oError <> "" THEN RETURN oError.

                IF nocheckbalance = NO THEN 
                 DO:
                    oError = TransactionCore:checkTransactionAmount(iTransaction).
                    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 501).
                 END.

                 oError = iTransaction:putDb().
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 502).

                /* To change Account Balance immediately */
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
                 oError = iTransaction:putDb().
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 502).

                IF change_balance_sign = YES THEN 
                    oError = transactionCore:changeGlBalance(iTransaction).
                ELSE
                 DO:
                    oError = transactionCore:createFutureAccountBalance(iTransaction).
                 END.
            END.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 505).
        END.
        
        CATCH eAnyError AS Progress.Lang.Error:
            /*oError =  oError + ":" + eAnyError:GetMessage(1).*/
            RETURN oError.
        END CATCH.

        FINALLY:
            RETURN oError.
        END.
    END.

    METHOD STATIC PUBLIC transactionLineModel createLineModel(iTransactionHeader AS transactionHeaderModel):
        DEFINE VARIABLE iTransactionLine AS transactionLineModel.
        initCore(""). /* TODO! */
        
        iTransactionLine = NEW transactionLineModel(iTransactionHeader).
        garbage:addItem(iTransactionLine).
        
        iTransactionLine:header_id    = iTransactionHeader:header_id.
        iTransactionLine:balance_date = iTransactionHeader:balance_date.
        
        RETURN iTransactionLine.
    END.
    
    METHOD STATIC PUBLIC transactionHeaderModel createHeaderModel():
        DEFINE VARIABLE iTransactionHeader AS transactionHeaderModel.
        initCore(""). /* TODO! */
        
        iTransactionHeader = NEW transactionHeaderModel().
        garbage:addItem(iTransactionHeader).
        iTransactionHeader:initDefaultSettings().
        
        RETURN iTransactionHeader.
    END.
    
    METHOD STATIC PUBLIC CHAR createHeader(INPUT-OUTPUT iTransactionHeader AS transactionHeaderModel):
        RETURN createHeader(INPUT-OUTPUT iTransactionHeader, 0).
    END.
    
    METHOD STATIC PUBLIC CHAR createHeader(INPUT-OUTPUT iTransactionHeader AS transactionHeaderModel, iDocumentId AS INT64):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        IF NOT VALID-OBJECT(iTransactionHeader) THEN
         DO:
            iTransactionHeader = createHeaderModel().
            iTransactionHeader:document_id = iDocumentId.
         END.
        
        oError = iTransactionHeader:putDb().
        
        RETURN oError.
    END.
    
    METHOD STATIC PUBLIC CHAR validateLine(iTransactionLine AS transactionLineModel):
    
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        
        oError = TransactionCore:validateTransactionAccount(iTransactionLine).
        
        /* TODO VALIDATE */
        
        RETURN oError.
    END.
    
    METHOD STATIC PUBLIC CHARACTER authorizeTransaction(iTransactionHeader AS transactionHeaderModel):
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
        DEFINE BUFFER transaction_line FOR transaction_line.
        
        IF NOT VALID-OBJECT(iTransactionHeader) THEN RETURN "ERROR-HEADER-UNDEFINED".
         DO TRANSACTION:
            FOR EACH transaction_line WHERE transaction_line.header_id = iTransactionHeader:header_id AND  
                transaction_line.state <> 9 :
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
    METHOD STATIC PUBLIC CHARACTER DeleteLine(iTransaction AS transactionLineModel, forced_key AS LOG, delete_header AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
                
        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = transactionCore:validateTransactionNumberLine(iTransaction:Header_Id,iTransaction:line).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 400).

            oError = transactionCore:validateBalanceDate(iTransaction:balance_date).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 500).
            
            oError = TransactionCore:checkTransactionAmountForDelete(iTransaction, forced_key).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 501).
            
            IF transactionCore:isFutureBalanceForLine(iTransaction) = NO THEN DO:   
                IF iTransaction:account NE "" THEN DO:
                    oError = transactionCore:changeAccountBalanceForDelete(iTransaction).
                    IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 504).    
                END.
                oError = transactionCore:changeGlBalanceForDelete(iTransaction).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 503).
            END.
            ELSE DO:
                oError = transactionCore:deleteFutureAccountBalance(iTransaction).   
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 505). /*??? 505 */
            END.
            oError = transactionCore:SetDeletedStatus(iTransaction, delete_header).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 506). /*??? 506 */
        END.    
            
           
        
        CATCH eAnyError AS Progress.Lang.Error:
            /*oError =  oError + ":" + eAnyError:GetMessage(1).*/
            RETURN oError.
        END CATCH.

        FINALLY:
            RETURN oError.
        END.
    END.
    METHOD STATIC PUBLIC CHARACTER DeleteLine(iHeader_Id AS INT64, iLine AS INT, forced_key AS LOG, delete_header AS LOG):
        DEFINE VARIABLE oError     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE iTransaction AS transactionLineModel.
                
        iTransaction = NEW transactionLineModel().
                
        DO TRANSACTION ON ERROR UNDO, THROW:
        
            oError = transactionCore:validateTransactionNumberLine(iHeader_Id,iLine).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError(oError, 400).
            oError = iTransaction:getDbByHeaderLine(iHeader_Id , iLine).
            /* Kak zapolnitj iTransaction ????????? 
            oError = iTransaction:getDb().
            iTransaction = getdb(transaction_line.id).*/
            RETURN DeleteLine(iTransaction,forced_key,delete_header).
               
        END.    
       
        CATCH eAnyError AS Progress.Lang.Error:
            /*oError =  oError + ":" + eAnyError:GetMessage(1).*/
            RETURN oError.
        END CATCH.

        FINALLY:
            RETURN oError.
        END.
    END.
END.