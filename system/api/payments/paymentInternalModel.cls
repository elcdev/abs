CLASS paymentInternalModel INHERITS paymentModel:
    
    CONSTRUCTOR paymentInternalModel():
        payment_type = "INTERNAL".
        payment_date = TODAY.
    END.
    
    METHOD PUBLIC OVERRIDE CHAR makeTransaction():
        DEFINE VARIABLE oError AS CHARACTER NO-UNDO.

        oError =  SUPER:makeTransaction().

        RETURN oError.
    END.
END.
