CLASS paymentConvertationModel INHERITS paymentModel:
    
    CONSTRUCTOR paymentConvertationModel():
        payment_type = "CONVERTATION".
        payment_date = TODAY.
    END.
    
    METHOD PUBLIC OVERRIDE CHAR makeTransaction():
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

        oError =  SUPER:makeTransaction().

        RETURN oError.
    END.
END.
