CLASS webApiType IMPLEMENTS webApiInterface:
    DEF PUBLIC VAR tPage    AS webFormInterface.
    
    METHOD PUBLIC responseType Invoke(iRequest AS requestType):
        IF NOT VALID-OBJECT(tPage) THEN
            DO:
                tPage = NEW templatePage().
                IF NOT iRequest:cSession:isLoggedIn THEN
                    DO:
                        iRequest:Name = "signin".
                    END.
            END.
        
        RETURN tPage:Action(iRequest).
    END.
    
    DESTRUCTOR webApiType():
        DELETE OBJECT tPage    NO-ERROR.
    END.

END.