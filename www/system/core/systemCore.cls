CLASS systemCore:
    DEF PUBLIC VAR response  AS responseType NO-UNDO.
    DEF PUBLIC VAR request   AS requestType  NO-UNDO.
    DEF PUBLIC VAR cSession  AS sessionCore  NO-UNDO.
    
    DEF PUBLIC VAR cssDependencies AS CHAR.
    DEF PUBLIC VAR jsDependencies  AS CHAR.
    
    CONSTRUCTOR systemCore():
        /*response = NEW responseType().*/
        request  = NEW requestType().
        cSession = NEW sessionCore(request).
    END.
    
    DESTRUCTOR systemCore():
        DELETE OBJECT response NO-ERROR.
        DELETE OBJECT request  NO-ERROR.
        DELETE OBJECT cSession NO-ERROR.
    END.
    
    METHOD PUBLIC CHAR getHtml():
        RETURN getHtml(request, response).
    END.
    
    METHOD PUBLIC CHAR getHtml(request as requestType, response AS responseType):
        putHeaders(request, response).
        IF response:contentType = "Location" THEN RETURN "".
        
        putHtmlHead(request, response).
        putNavigationBar(response).
        putContent(response).
        putFooter(response).
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR putHeaders(request AS requestType, response AS responseType):
        CASE response:contentType:
            WHEN "Location" THEN 
                IF response:content BEGINS "http" THEN
                    MESSAGE "Location: " + STRING(response:content).
            ELSE
                MESSAGE "Location: " request:https + "://" + request:host + STRING(response:content).
            OTHERWISE
             DO:
                MESSAGE "Content-type: " response:contentType.
             END.
        END CASE.
        
        MESSAGE request:cookieParameters:getCookies().
        MESSAGE "".
    END.
    
    METHOD PUBLIC LONGCHAR getHtmlFileContent(iFileName AS CHAR):
        DEF VAR content AS LONGCHAR NO-UNDO.
        copy-lob FILE SEARCH(iFileName) TO content.
        RETURN content.
    END.
    
    METHOD PUBLIC CHAR putHtmlFile(response AS responseType, iFileName AS CHAR):
        RETURN putLongchar(getHtmlFileContent(iFileName)).
    END.
    
    METHOD PUBLIC CHAR putHtmlHead(request AS requestType, response AS responseType):
        DEF VAR content AS LONGCHAR NO-UNDO.
        
        IF response:contentType <> "text/html" THEN RETURN "".
        
        copy-lob FILE SEARCH("header.html") TO content.
        
        /* Put custom CSS and JS */
        cssDependencies = cssDependencies + getStyleSheetLink(request:name + ".css").
        content = REPLACE(content, "[customCss]", cssDependencies).
        
        MESSAGE STRING(content).
        
        RETURN "".
    END.
    
    METHOD CHAR getStyleSheetLink(iFileName AS CHAR):
        DEF VAR iFile AS CHAR.
        DEF VAR tPublic AS INT NO-UNDO.
        
        iFile = SEARCH(iFileName).
        IF iFile = ? THEN iFile = SEARCH("public/pages/css/" + iFileName).
        IF iFile = ? THEN RETURN "<!--- no file " +  iFileName + "--->".
        
        tPublic = INDEX(iFile, "www/public/").
        IF tPublic < 1 THEN RETURN "".
        
        iFile = SUBSTRING(iFile, tPublic + 10).
        RETURN '<link href="' + iFile + '" rel="stylesheet">'.
    END.
    
    METHOD PUBLIC CHAR putNavigationBar(response AS responseType):
        DEFINE VARIABLE content AS LONGCHAR NO-UNDO.
        
        IF response:contentType <> "text/html" THEN RETURN "".
        
        content = getHtmlFileContent("navigationBar.html").
        response:content = content + response:content.
        
        IF cSession:isLoggedIn THEN
            DO:
                response:setVar("signinAction", "logout").
                response:setVar("signinDesc", "LogOut").
            END.
        ELSE
            DO:
                response:setVar("signinAction", "get").
                response:setVar("signinDesc", "SignIn").
            END.
    END.
    
    METHOD PUBLIC CHAR putFooter(response AS responseType):
        IF response:contentType <> "text/html" THEN RETURN "".
        putHtmlFile(response, "footer.html").
    END.
    
    METHOD PUBLIC CHAR putContent(response AS responseType):
        RETURN putLongchar(response:content).
    END.
    
    METHOD CHAR putLongchar(iString AS LONGCHAR):
        DEF VAR i AS INT NO-UNDO INIT 1.
        
        DO WHILE i < LENGTH(iString):
            PUT UNFORMATTED STRING(SUBSTRING(iString, i, 1000)).
            i = i + 1000.
        END.
        
        RETURN "".
    END.
END.