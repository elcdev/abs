CLASS formProfile INHERITS webFormType:

    METHOD PUBLIC OVERRIDE responseType Action(iRequest AS requestType):
        request = iRequest.

        CASE iRequest:Action:
            WHEN "" OR WHEN "get" THEN RETURN getHtml(iRequest).
        END CASE.
            
        RETURN SUPER:Action(iRequest).
    END.


    METHOD PUBLIC OVERRIDE responseType getHtml(iRequest AS requestType):
        /*DEF VAR cUsers AS usersType.*/
        DEF VAR tLogin AS CHAR.
        
        tLogin = iRequest:cSession:Parameters:Item("userName").


        response:loadTemplate("profile.html").
    /*
        IF cUsers:getDb(tLogin) <> "" THEN 
             DO:
            response:setVar("name",  "----").
            response:setError("Check user name!").
            RETURN response.
         END.

        response:setVar("email", cUsers:email).
        response:setVar("name",  cUsers:firstName)
    */
        response:setVar("name",  tLogin).


        response:processError().

        RETURN response.
    END.

END CLASS.
