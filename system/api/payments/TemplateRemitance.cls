USING system.api.systemSettings.*.
USING system.api.payments.*.

CLASS system.api.payments.TemplateRemitance: /*IMPLEMENTS transactionTemplateInterface:*/
	DEF TEMP-TABLE transactionLines LIKE transaction_line.
	
	/* Returns "" if ok */
	METHOD PUBLIC CHAR getTransactionLines(INPUT-OUTPUT TABLE transactionLines):
    
    END.

END.