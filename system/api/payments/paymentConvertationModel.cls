CLASS paymentConvertationModel INHERITS paymentModel:
    
    {propertyGetSet.f &name="rate"            &type="DECIMAL"}
    {propertyGetSet.f &name="revenue"         &type="DECIMAL"}
    {propertyGetSet.f &name="sell_currency"   &type="CHAR"}
    {propertyGetSet.f &name="sell_amount"     &type="DECIMAL"}
       
       
    CONSTRUCTOR paymentConvertationModel():
        payment_type = "CONVERTATION".
        payment_date = TODAY.
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER validate():
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.
        
        oError = SUPER:VALIDATE().
        
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError, 1).
        
        oError = transactionCore:validateCurrency(sell_currency).
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ", Sell currency", 1).
        IF rate EQ 0.0 then UNDO, THROW NEW Progress.Lang.AppError ("ERROR-INCORRECT-RATE", 1). 
        IF sell_amount EQ 0.0 then UNDO, THROW NEW Progress.Lang.AppError ("ERROR-SELL-AMOUNT", 1).   
            /* TODO Proverka sootvetstvija schetov i valjut */
        RETURN oError.
    END.
    
    METHOD PUBLIC CHARACTER calculate_revenue():
        DEFINE VARIABLE oError          AS CHARACTER NO-UNDO.
        
        FIND LAST currency_rates WHERE currency_rates.currency = currency AND 
        currency_rates.rate_type = "BUY" AND currency_rates.balance_date LE globalSettings:balance_date
        NO-LOCK NO-ERROR.
        IF NOT AVAILABLE currency_rates THEN oError = "NO-RATES-BUY-CURRENCY".
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError, 1).
        
        revenue = ROUND(amount * currency_rates.rate / currency_rates.unit,2).
        FIND LAST currency_rates WHERE currency_rates.currency = sell_currency AND 
        currency_rates.rate_type = "SELL" AND currency_rates.balance_date LE globalSettings:balance_date
        NO-LOCK NO-ERROR.
        IF NOT AVAILABLE currency_rates THEN oError = "NO-RATES-SELL-CURRENCY".
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError, 1).
        revenue = revenue - ROUND(sell_amount * currency_rates.rate / currency_rates.unit,2).
        
        RETURN oError.
    END.
    
    METHOD PUBLIC OVERRIDE CHARACTER makeTransaction():
        DEFINE VARIABLE trHeader                    AS transactionHeaderModel.
        
        DEFINE VARIABLE debetLine                   AS transactionLineModel.
        DEFINE VARIABLE creditLine                  AS transactionLineModel.
        
        DEFINE VARIABLE conversionCreditLine        AS transactionLineModel.
        DEFINE VARIABLE conversionDebetLine         AS transactionLineModel.
        
        DEFINE VARIABLE conversionIncomeDebetLine   AS transactionLineModel.
        DEFINE VARIABLE conversionIncomeCreditLine  AS transactionLineModel.
        
        DEFINE VARIABLE details_conversion          AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oError                      AS CHARACTER NO-UNDO.


        DO TRANSACTION ON ERROR UNDO, THROW:
            oError = putDb().
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-PUT-DB", 1).
            
            oError = transactionApi:createHeader(INPUT-OUTPUT trHeader, id).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-HEADER", 1).

            debetLine                   = transactionApi:createLineModel(trHeader).
            creditLine                  = transactionApi:createLineModel(trHeader).
            conversionCreditLine        = transactionApi:createLineModel(trHeader).
            conversionDebetLine         = transactionApi:createLineModel(trHeader).
            conversionIncomeDebetLine   = transactionApi:createLineModel(trHeader).
            conversionIncomeCreditLine  = transactionApi:createLineModel(trHeader).
            
            /* !TODO Create lines */
            oError = debetLine:setLineData(sender_account, "D", amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-DEBET-DATA", 1).

            oError = conversionCreditLine:setLineData(paymentConstants:conversion_gl, "C", amount, currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).

            oError = conversionDebetLine:setLineData(paymentConstants:conversion_gl, "D", sell_amount, sell_currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-DEBET-DATA", 1).
            
            oError = CreditLine:setLineData(beneficiary_account, "C", sell_amount, sell_currency, details).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).

            /* Income lines */
            details_conversion = SUBSTITUTE(paymentConstants:conversion_details, "FX").
            IF revenue > 0 THEN DO:
                oError = conversionIncomeDebetLine:setLineData(paymentConstants:conversion_gl, "D", revenue, paymentConstants:national_currency, details_conversion).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-INCOME-DEBET-DATA", 1).  
                oError = conversionIncomeCreditLine:setLineData(paymentConstants:conversion_income_gl, "C", revenue, paymentConstants:national_currency, details_conversion).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-INCOME-CREDIT-DATA", 1). 
            END.
            ELSE IF revenue < 0 THEN DO:    
                revenue = - revenue.
                oError = conversionIncomeDebetLine:setLineData(paymentConstants:conversion_income_gl, "D", revenue, paymentConstants:national_currency, details_conversion).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-INCOME-DEBET-DATA", 1).  
                oError = conversionIncomeCreditLine:setLineData(paymentConstants:conversion_gl, "C", revenue, paymentConstants:national_currency, details_conversion).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-INCOME-CREDIT-DATA", 1). 
            END.
            
             

            /* Make transaction in db */
            oError = transactionApi:createLine(debetLine, FALSE, TRUE).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-DEBET;" + debetLine:account, 1).
            oError = transactionApi:createLine(conversionCreditLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-CREDIT", 1).

            oError = transactionApi:createLine(conversionDebetLine, FALSE, TRUE).
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-DEBET", 1).
            oError = transactionApi:createLine(creditLine, FALSE, TRUE) NO-ERROR.
            IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-CREDIT", 1).
                     
            IF revenue NE 0.0 then DO:
                oError = transactionApi:createLine(conversionIncomeDebetLine, FALSE, TRUE).
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-DEBET", 1).
                oError = transactionApi:createLine(conversionIncomeCreditLine, FALSE, TRUE) NO-ERROR.
                IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-FEE-CREDIT", 1).
            END.
            
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
                DELETE OBJECT conversionCreditLine  NO-ERROR.
                DELETE OBJECT conversionDebetLine NO-ERROR.
                DELETE OBJECT conversionIncomeCreditLine  NO-ERROR.
                DELETE OBJECT conversionIncomeDebetLine NO-ERROR.
            END.
        END.
        
        RETURN oError.
    END.
END.
