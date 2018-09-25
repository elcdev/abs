USING system.api.payments.*.
USING system.api.systemSettings.*.

DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
DEF VAR payment AS paymentInternalModel.

RUN startupSettings.p. 

payment = NEW paymentInternalModel().

DO:
    payment:payment_date        = globalSettings:balance_date.
    payment:value_date          = globalSettings:balance_date.
    
    payment:amount              = 2.36.
    payment:currency            = "EUR".
    payment:sender_account      = "123456789012". 
    payment:beneficiary_account = "C00000000003".
    payment:details             = "Test of internal payment".
    payment:urgency             = "standard".
    payment:payment_type        = "internal".
    
    payment:fee_currency        = "EUR".
    payment:fee_account         = "". /* Same as sender's account */
    payment:fee_amount          = 0.36.
    
END.

oError = payment:makeTransaction().

IF oError <> "" THEN
    MESSAGE "Eror" SKIP oError VIEW-AS ALERT-BOX.
ELSE    
    MESSAGE "Successfully made payment" SKIP "payment:id = " payment:id VIEW-AS ALERT-BOX.

/*DELETE OBJECT payment.*/

