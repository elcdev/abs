CLASS formSignIn INHERITS webFormType:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
	request = iRequest.

	CASE iRequest:Action:
	    WHEN "login" THEN RETURN login(iRequest).
	    WHEN "logout" THEN RETURN logout(iRequest).
	END CASE.
	    
	RETURN SUPER:Action(iRequest).
    END.

    METHOD PUBLIC responseType login(iRequest AS requestType):

	IF iRequest:postParameters:item("email") = "user@home.com" THEN
         DO:
	    IF iRequest:postParameters:item("password") = "user" THEN
	     DO:
		request:cSession:setLoggedIn(iRequest:postParameters:item("email")).
		response:redirect("/pages/menu/").
		RETURN response.
	     END.
	    
	    response:setError("Invalid password for given user!").
	 END.
	ELSE
	 DO:
	    response:setError("Check user name and password!").
	 END.

	RETURN getHtml(iRequest).
    END.

    METHOD PUBLIC responseType logout(iRequest AS requestType):
	request:cSession:setLoggedOut().
	RETURN getHtml(iRequest).
    END.

    METHOD PUBLIC OVERRIDE responseType getHtml(iRequest AS requestType):
	response:loadTemplate("signin.html").
	response:setByPostVar("email", iRequest).
	response:setByPostVar("name",  iRequest).
	response:processError().

        RETURN response.
    END.

END CLASS.
