DEFINE VARIABLE oError AS CHARACTER NO-UNDO.
DEF VAR payment AS paymentInternalModel.

RUN startupSettings.p. 

payment = NEW paymentInternalModel().

DO:
    payment:payment_date        = globalSettings:balance_date.
    payment:value_date          = globalSettings:balance_date.
    
    payment:amount              = 100.
    payment:currency            = "EUR".
    payment:sender_account      = "A100000".
    payment:beneficiary_account = "A200000".
    payment:details             = "Test of internal payment".
    payment:urgency             = "standart".
    payment:payment_type        = "internal".
    
    payment:fee_currency        = "EUR".
    payment:fee_account         = "F100000".
    payment:fee_amount          = 1.20.
    
END.

oError = payment:makeTransaction().

IF oError <> "" THEN
    MESSAGE "Erorr" SKIP oError VIEW-AS ALERT-BOX.
ELSE    
    MESSAGE "Successfully made payment" SKIP "payment:id = " payment:id VIEW-AS ALERT-BOX.

/*DELETE OBJECT payment.*/

