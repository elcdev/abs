CLASS paymentModel INHERITS dbModel:
    {propertyGetSet.f &name="payment_type"              &type="CHARACTER"}
    
    {propertyGetSet.f &name="payment_date"              &type="DATE"}
    {propertyGetSet.f &name="amount"                    &type="DECIMAL"}
    {propertyGetSet.f &name="currency"                  &type="CHARACTER"}
    {propertyGetSet.f &name="details"                   &type="CHARACTER"}
    {propertyGetSet.f &name="urgency"                   &type="CHARACTER"}
    {propertyGetSet.f &name="value_date"                &type="DATE"}
    
    {propertyGetSet.f &name="sender_name"               &type="CHARACTER"}
    {propertyGetSet.f &name="sender_account"            &type="CHARACTER"}
    {propertyGetSet.f &name="sender_bank_name"          &type="CHARACTER"}
    {propertyGetSet.f &name="sender_bank_address"       &type="CHARACTER"}
    {propertyGetSet.f &name="sender_bank_swift"         &type="CHARACTER"}
    
    {propertyGetSet.f &name="beneficiary_name"          &type="CHARACTER"}
    {propertyGetSet.f &name="beneficiary_account"       &type="CHARACTER"}
    {propertyGetSet.f &name="beneficiary_bank_name"     &type="CHARACTER"}
    {propertyGetSet.f &name="beneficiary_bank_address"  &type="CHARACTER"}
    {propertyGetSet.f &name="beneficiary_bank_swift"    &type="CHARACTER"}    
    
    {propertyGetSet.f &name="nostro_account"            &type="CHARACTER"}
    {propertyGetSet.f &name="intermediary_bank_name"    &type="CHARACTER"}
    {propertyGetSet.f &name="intermediary_bank_swift"   &type="CHARACTER"}
    {propertyGetSet.f &name="intermediary_bank_address" &type="CHARACTER"}
    
    {propertyGetSet.f &name="fee_account"               &type="CHARACTER"}
    {propertyGetSet.f &name="fee_amount"                &type="DECIMAL"}
    {propertyGetSet.f &name="fee_currency"              &type="CHARACTER"}
    
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

            oError = transactionCore:validateCurrency(fee_currency).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Fee currency", 1).
            
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
        DEFINE VARIABLE trHeader        AS transactionHeaderModel.
        DEFINE VARIABLE debetLine       AS transactionLineModel.
        DEFINE VARIABLE creditLine      AS transactionLineModel.
        DEFINE VARIABLE feeLine         AS transactionLineModel.

        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.

        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = putDb().
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-PUT-DB", 1).
            
            oError = transactionApi:createHeader(INPUT-OUTPUT trHeader, id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-HEADER", 1).

            debetLine  = transactionApi:createLineModel(trHeader).
            creditLine = transactionApi:createLineModel(trHeader).
            feeLine    = transactionApi:createLineModel(trHeader).

            /* !TODO Create lines */
            oError = creditLine:setLineData(beneficiary_account, "C", amount + fee_amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).
            oError = debetLine:setLineData(sender_account, "D", amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-DEBET-DATA", 1).
            /*
            oError = feeLine:setLineData(fee_account, "D", fee_amount, fee_currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-FEE-DATA", 1).
             */
            oError = transactionApi:createLine(creditLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-CREDIT", 1).
            oError = transactionApi:createLine(debetLine, FALSE, TRUE).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-DEBET", 1).
            /*
            oError = transactionApi:createLine(feeLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE", 1).
            */
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
                DELETE OBJECT feeLine    NO-ERROR.
            END.
        END.
        
        RETURN oError.
    END.
END.