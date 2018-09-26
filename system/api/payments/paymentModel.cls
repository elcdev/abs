USING system.api.core.*.
USING system.api.payments.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.


CLASS system.api.payments.paymentModel SERIALIZABLE INHERITS dbModel:
    {propertyGetSet.f &name="payment_type"              &type="CHARACTER" &serializable="serializable"}
    
    {propertyGetSet.f &name="payment_date"              &type="DATE" &serializable="serializable"}
    {propertyGetSet.f &name="amount"                    &type="DECIMAL" &serializable="serializable"}
    {propertyGetSet.f &name="currency"                  &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="details"                   &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="urgency"                   &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="value_date"                &type="DATE" &serializable="serializable"}
    
    {propertyGetSet.f &name="sender_name"               &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="sender_account"            &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="sender_bank_name"          &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="sender_bank_address"       &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="sender_bank_swift"         &type="CHARACTER" &serializable="serializable"}
    
    {propertyGetSet.f &name="beneficiary_name"          &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="beneficiary_account"       &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="beneficiary_bank_name"     &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="beneficiary_bank_address"  &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="beneficiary_bank_swift"    &type="CHARACTER" &serializable="serializable"}    
    
    {propertyGetSet.f &name="nostro_account"            &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="intermediary_bank_name"    &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="intermediary_bank_swift"   &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="intermediary_bank_address" &type="CHARACTER" &serializable="serializable"}
    
    {propertyGetSet.f &name="fee_account"               &type="CHARACTER" &serializable="serializable"}
    {propertyGetSet.f &name="fee_amount"                &type="DECIMAL" &serializable="serializable"}
    {propertyGetSet.f &name="fee_currency"              &type="CHARACTER" &serializable="serializable"}
    
    {dbModelJsonParser.f &class="system.api.payments.paymentModel"}
    
    METHOD PUBLIC OVERRIDE CHARACTER putDb():
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.
        {requestItemPutDb.f &TABLE="payments"}
        oError = validate().
        IF oError <> "" THEN RETURN oError.
        
        RETURN setValuesToBuffer(BUFFER payments:handle).
	END.
    
    METHOD PUBLIC OVERRIDE CHARACTER getDb(iId AS INT64):
        {requestItemGetDbByField.f &table="payments" &field="id"}
        RETURN super:getValuesFromBuffer(BUFFER payments:handle).
	END.
    
    METHOD PRIVATE CHARACTER validatePaymentType():
        IF INDEX("INTERNAL,INTERNATIONAL,CONVERTATION,", payment_type + ",") < 0 THEN RETURN "ERROR-".
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER validate():
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.
        /* TODO */
        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = transactionCore:validateCurrency(currency).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Payment currency", 1).

            IF payment_type <> 'CONVERTATION' THEN
             DO:
                oError = transactionCore:validateCurrency(fee_currency).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Fee currency", 1).
             END.
            /* TODO! Skip account veryfication for non internal accounts */
            oError = transactionCore:validateAccount(sender_account).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Sender account", 1).
            oError = transactionCore:validateAccount(beneficiary_account).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Beneficiary account", 1).
            
            /*
            oError = transactionCore:validateAccount(nostro_account).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Nostro account", 1).
            */
            
            IF INDEX("standart,express,", urgency + ",") < 0 THEN UNDO, THROW NEW Progress.Lang.AppError ("ERROR-INVALID-URGENCY", 1).
            oError = validatePaymentType().
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Payment type", 1).
            
            CATCH eAnyError AS Progress.Lang.Error:
                RETURN oError.
            END CATCH.
            
            FINALLY:
                RETURN oError.
            END.
        END.
        
        RETURN oError.
    END.
    
    METHOD PUBLIC CHARACTER makeTransaction():
        DEFINE VARIABLE trHeader           AS transactionHeaderModel.
        DEFINE VARIABLE debetLine          AS transactionLineModel.
        DEFINE VARIABLE creditLine         AS transactionLineModel.
        DEFINE VARIABLE feeDebetLine       AS transactionLineModel.
        DEFINE VARIABLE feeCreditLine      AS transactionLineModel.
        DEFINE VARIABLE details_commission AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oError             AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tFeeAccount        AS CHARACTER NO-UNDO.

        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = putDb().
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-PUT-DB", 1).
            
            oError = transactionApi:createHeader(INPUT-OUTPUT trHeader, id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-HEADER", 1).

            debetLine     = transactionApi:createLineModel(trHeader).
            creditLine    = transactionApi:createLineModel(trHeader).
            feeDebetLine  = transactionApi:createLineModel(trHeader).
            feeCreditLine = transactionApi:createLineModel(trHeader).

            /* !TODO Create lines */
            oError = debetLine:setLineData(sender_account, "D", amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-DEBET-DATA", 1).

            oError = creditLine:setLineData(beneficiary_account, "C", amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).

            /* Commission lines */
            details_commission = SUBSTITUTE(paymentConstants:payment_internal_fee_details, "").
            IF fee_account <> "" THEN tFeeAccount = fee_account. ELSE tFeeAccount = sender_account.
            
            oError = feeDebetLine:setLineData(tFeeAccount, "D", fee_amount, fee_currency, details_commission).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-FEE-DEBET-DATA", 1).

            oError = feeCreditLine:setLineData(paymentConstants:payment_internal_fee_gl, "C", fee_amount, fee_currency, details_commission).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-FEE-CREDIT-DATA", 1).

            /* Make transaction in db */
            oError = transactionApi:createLine(debetLine, FALSE, TRUE).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-DEBET;" + debetLine:account, 1).
            oError = transactionApi:createLine(creditLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-CREDIT", 1).

            oError = transactionApi:createLine(feeDebetLine, FALSE, TRUE).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-DEBET", 1).
            oError = transactionApi:createLine(feeCreditLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-CREDIT", 1).
            
            CATCH eAnyError AS Progress.Lang.Error:
                /* TODO! Remove message after testing */
                MESSAGE "Error in transaction: " SKIP eAnyError:GetMessage(1) VIEW-AS ALERT-BOX.
                RETURN oError.
            END CATCH.
            
            FINALLY:
                /* TODO! Remove message after testing, Save header_id  */
                DELETE OBJECT trHeader   NO-ERROR.
                DELETE OBJECT debetLine  NO-ERROR.
                DELETE OBJECT creditLine NO-ERROR.
                DELETE OBJECT feeDebetLine  NO-ERROR.
                DELETE OBJECT feeCreditLine NO-ERROR.
            END.
        END.
        
        RETURN oError.
    END.
END.