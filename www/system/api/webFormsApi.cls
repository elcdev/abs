CLASS webFormsApi INHERITS webApiType IMPLEMENTS webApiInterface:

    METHOD PUBLIC OVERRIDE responseType Invoke(iRequest AS requestType):
        CASE iRequest:name:
	    WHEN "formCrc"    THEN tPage = NEW webFormCrc().
	    WHEN "signin"     THEN tPage = NEW formSignIn().
	    WHEN "profile"    THEN tPage = NEW formProfile().
	END.

	RETURN super:invoke(iRequest).
    END.

END.