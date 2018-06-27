CLASS webPagesApi INHERITS webApiType IMPLEMENTS webApiInterface:

    METHOD PUBLIC OVERRIDE responseType Invoke(iRequest AS requestType):
        CASE iRequest:name:
	    WHEN "dashboard" THEN tPage = NEW dashboardPage().
	END.

	RETURN super:invoke(iRequest).
    END.

END.