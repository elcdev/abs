CLASS paymentInternationalModel INHERITS paymentModel:
    
    CONSTRUCTOR paymentInternationalModel():
        payment_type = "INTERNATIONAL".
        payment_date = TODAY.
    END.
    
    METHOD PUBLIC OVERRIDE CHAR makeTransaction():
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

        oError =  SUPER:makeTransaction().

        RETURN oError.
    END.
END.
