CLASS dashboardPage INHERITS webFormType:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
	request = iRequest.

	CASE iRequest:Action:
	    WHEN "submit"    THEN RETURN response.
	END CASE.
	    
	RETURN SUPER:Action(iRequest).
    END.

    METHOD PUBLIC OVERRIDE responseType getHtml(iRequest AS requestType):
	DEF VAR tForm AS webFormCrc.
run df.p("dash").
	tForm = NEW webFormCrc().

	response:loadTemplate("dashboardPage.html").
	response:setVar("form", tForm:getHtml(iRequest)).
	response:setVar("form2", tForm:getHtml(iRequest)).

        RETURN response.
    END.

END CLASS.
