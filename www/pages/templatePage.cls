CLASS templatePage INHERITS webFormType:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
        RETURN SUPER:Action(iRequest).
    END.

    METHOD PUBLIC OVERRIDE responseType getHtml(iRequest AS requestType):
        response:loadTemplate(iRequest:name + ".html").

        RETURN response.
    END.
END CLASS.
