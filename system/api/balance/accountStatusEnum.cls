USING system.api.balance.*.

CLASS system.api.balance.accountStatusEnum:
    DEFINE PUBLIC STATIC PROPERTY active AS CHARACTER GET: RETURN "active". END.
    DEFINE PUBLIC STATIC PROPERTY closed AS CHARACTER GET: RETURN "closed". END.
    
    METHOD PUBLIC STATIC LOG isValid (iStatus AS CHARACTER):
        IF  INDEX("active,closed,", iStatus + ",") > 0 THEN RETURN TRUE.
        RETURN FALSE.
    END.
END CLASS.