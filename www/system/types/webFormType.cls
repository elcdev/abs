CLASS webFormType INHERITS webType IMPLEMENTS webFormInterface:
    DEF PUBLIC VAR request  AS requestType  NO-UNDO.
    DEF PUBLIC VAR response AS responseType NO-UNDO.
    DEF PUBLIC VAR cSession AS sessionCore  NO-UNDO.

    CONSTRUCTOR webFormType():
	response = NEW responseType().
    END.

    CONSTRUCTOR webFormType(iRequest AS requestType):
	response = NEW responseType().
	request  = iRequest.
    END.

    DESTRUCTOR webFormType():
	DELETE OBJECT response NO-ERROR.
    END.

    METHOD PUBLIC responseType Action(iFormSlug AS requestType):
        request  = iFormSlug.
        
	CASE iFormSlug:Action:
	    WHEN "submit" THEN         RETURN Submit().
	    WHEN "get" OR WHEN "" THEN RETURN getHtml(request).
	END CASE.
	    
	RETURN response.
    END.

    METHOD PUBLIC responseType Submit():
        RETURN response.
    END.

    METHOD PUBLIC responseType getHtml(iRequest AS requestType):
        response:content = "<B>Empty form</B><BR>" + iRequest:slug.
        
        RETURN response.
    END.

END CLASS.
