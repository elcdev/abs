USING system.api.balance.*.

CLASS system.api.balance.accountGroupEnum:
    /* TODO!!! */
    DEFINE PUBLIC STATIC PROPERTY default AS CHARACTER GET: RETURN "". END.
    /*DEFINE PUBLIC STATIC PROPERTY closed AS CHARACTER GET: RETURN "closed". END.*/
  
    METHOD PUBLIC STATIC LOG isValid (iGroup AS CHARACTER):
        IF  INDEX(",,,", iGroup + ",") > 0 THEN RETURN TRUE.
        RETURN FALSE.
    END.
END CLASS.