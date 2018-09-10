CLASS accountCore:
    DEFINE STATIC VARIABLE MAX-ACCOUNT-LENGTH         AS INTEGER NO-UNDO INITIAL 12.
    
    DEFINE STATIC VARIABLE garbage      AS garbageCollectorType.
    
    CONSTRUCTOR STATIC accountCore():
        garbage      = NEW garbageCollectorType().
    END.
    
    DESTRUCTOR accountCore():
        DELETE OBJECT garbage     NO-ERROR.
    END.

    METHOD STATIC PUBLIC CHARACTER getAccountByIban(iIban AS CHARACTER): 
        DEFINE BUFFER account FOR account.
        
        FIND FIRST account WHERE account.iban  = iIban NO-LOCK NO-ERROR.
        IF AVAILABLE account THEN RETURN account.account.
        
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER getOverdraftAccount(iAccount AS CHARACTER): 
        DEFINE BUFFER account FOR account.
        
        FIND FIRST account WHERE account.account  = iAccount NO-LOCK NO-ERROR.
        IF AVAILABLE account THEN RETURN account.overdraft_account.
        
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER getBaseAccount(iAccount AS CHARACTER): 
        DEFINE BUFFER account FOR account.
        
        IF LENGTH(iAccount) > MAX-ACCOUNT-LENGTH THEN iAccount = getAccountByIban(iAccount).
        
        FIND FIRST account WHERE account.account  = iAccount NO-LOCK NO-ERROR.
        IF AVAILABLE account THEN RETURN account.base_account.
        
        RETURN "".    
    END.
    
    METHOD STATIC PUBLIC CHARACTER getAccountInCurrency(iAccount AS CHARACTER, iCurrency AS CHAR): 
        DEFINE BUFFER account FOR account.
        
        DEFINE VARIABLE baseAccount AS CHARACTER NO-UNDO.
        baseAccount = getBaseAccount(iAccount).
        
        FIND FIRST account WHERE account.base_account  = baseAccount AND account.currency = iCurrency NO-LOCK NO-ERROR.
        IF AVAILABLE account THEN RETURN account.account.
        
        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validateGlAccount(iGl AS INT64):
        DEFINE BUFFER gl FOR gl.
        
        FIND gl WHERE gl.gl = iGl NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE gl THEN DO:
            RETURN "ERROR-GL-NOT-FOUND:Balance account " + string(iGl) +  " is incorrect!".
        END.
        
        IF gl.restrict_operation eq YES THEN DO:
            RETURN "ERROR-GL-RESTRICTED:Balance account " + string(iGl) + " is closed for operations!".
        END.
        
        RETURN "".
    END.
    

    METHOD STATIC PUBLIC LOG isValidGlAccount(iGl AS INT):
        IF validateGlAccount(iGl) = "" THEN RETURN TRUE.
        RETURN FALSE.
    END.
    
END.