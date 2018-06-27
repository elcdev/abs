CLASS menuPage INHERITS templatePage:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
	RETURN SUPER:Action(iRequest).
    END.

END CLASS.
