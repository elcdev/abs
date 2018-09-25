USING system.api.core.*.
USING system.api.payments.*.
USING system.api.systemSettings.*.

CLASS templateTransactionGenerator:
    DEF TEMP-TABLE transactionLines NO-UNDO LIKE transaction_line.

	METHOD PUBLIC CHAR prepareTransaction(iTransactionTemplate AS transactionTemplateInterface):
		iTransactionTemplate:getTransactionLines(INPUT-OUTPUT TABLE transactionLines).
	END.
    
    METHOD CHAR generateTransactions (iTemplate AS paymentTemplateModel):
        DEF VAR payment AS basicRemitanceModel.
        
        IF iTemplate:paymentType = "internal" THEN
         DO:
            payment = NEW internarnalPaymentModel().
         END.
        ELSE IF iTemplate:paymentType = "INTERNATIONAL" THEN
         DO:
            payment = NEW internationalPaymentModel().
         END.
        
        oError = iTemplate:calculateFieldsWithFormula().
        IF eError <> "" THEN RETURN oError.
        
        oError = iTemplate:fillDetailsTemplate().
        IF eError <> "" THEN RETURN oError.
        
        oError = payment:fillByTemplateTemplate(iTemplate).
        IF eError <> "" THEN RETURN oError.
        
        oError = payment:validate()
        IF eError <> "" THEN RETURN oError.
        
        oError = payment:makeTransaction().
        
        IF eError <> "" THEN RETURN oError.
    END.
	
END.