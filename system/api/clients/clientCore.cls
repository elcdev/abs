USING system.api.core.*.
USING system.api.clients.*.

CLASS system.api.clients.clientCore:
        DEFINE STATIC VARIABLE garbage      AS garbageCollectorType.
    
    CONSTRUCTOR STATIC clientCore():
        garbage      = NEW garbageCollectorType().
    END.
    
    DESTRUCTOR clientCore():
        DELETE OBJECT garbage     NO-ERROR.
    END.

    METHOD STATIC PUBLIC INT64 getClientId(iCif AS CHARACTER): 
        DEFINE BUFFER client FOR client.
        
        FIND FIRST client WHERE client.cif = iCif NO-LOCK NO-ERROR.

        IF AVAILABLE client THEN RETURN client.id.
        
        RETURN 0.
    END.    
    
    METHOD STATIC PUBLIC CHARACTER generateNewCif():
        DEFINE VARIABLE oCif AS CHARACTER NO-UNDO.
                        
        REPEAT WHILE TRUE:
            oCif = CAPS(SUBSTRING(GUID, 30, 6)).
            IF getClientId(oCif) = 0 THEN LEAVE.
        END.
        
        RETURN oCif.
    END.
    
END.