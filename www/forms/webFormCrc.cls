CLASS webFormCrc INHERITS webFormType:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
	request = iRequest.

	CASE iRequest:Action:
	    WHEN "submit"    THEN 
             DO:
		response:contentType = "text/json".
		response:content = "\{name:[name], id:123,email:[email]\}".
		response:setByPostVar("email", iRequest).
		response:setByPostVar("name", iRequest).

		RETURN response.
	     END.
	    WHEN "csv" THEN
             DO:
		RETURN makeCsvReport(iRequest).
	     END.
	    WHEN "ss.com" THEN
             DO:
		response:redirect("https://ss.com").
		RETURN response.
	     END.
	END CASE.
	    
	RETURN SUPER:Action(iRequest).
    END.

    METHOD PUBLIC OVERRIDE responseType Submit():
	response:content = "Form submited".

	RETURN response.
    END.

    METHOD PUBLIC responseType makeCsvReport(iRequest AS requestType):
	response:contentType = "text/csv".
    	response:content = "C1;C2;C3".
	RETURN response.
    END.

    METHOD PUBLIC OVERRIDE responseType getHtml(iRequest AS requestType):
	response:loadTemplate("webFormCrc.html").
	response:setByPostVar("email", iRequest).
	response:setByPostVar("name", iRequest).

        RETURN response.
    END.

END CLASS.
