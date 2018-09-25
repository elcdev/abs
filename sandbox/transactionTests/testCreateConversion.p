USING system.api.payments.*.
USING system.api.systemSettings.*.

DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

DEF VAR payment AS paymentConvertationModel.

RUN startupSettings.p. 

payment = NEW paymentConvertationModel().

DO:
    payment:payment_date        = globalSettings:balance_date.
    payment:value_date          = globalSettings:balance_date.
    
    payment:amount              = 100.00.
    payment:currency            = "EUR".
    payment:sender_account      = "123456789012". 
    payment:beneficiary_account = "C00000000004".
    payment:sell_currency       = "USD".
    payment:sell_amount         = 120.00.
    payment:rate                = 1.2.
    payment:details             = "Test of conversion payment".
    
    
    
    
END.
oError = payment:validate().
oError = payment:calculate_revenue().
oError = payment:makeTransaction(). 

IF oError <> "" THEN
    MESSAGE "Error" SKIP oError VIEW-AS ALERT-BOX.
ELSE    
    MESSAGE "Successfully made payment" SKIP "payment:id = " payment:id VIEW-AS ALERT-BOX.

/*DELETE OBJECT payment.*/

