CLASS sessionCore:
    DEF PUBLIC VAR sessionId 		    AS CHAR NO-UNDO INIT "".
    DEF PUBLIC VAR sessionCookieName	AS CHAR NO-UNDO INIT "sid".
    DEF PUBLIC VAR Parameters		    AS stringArrayType NO-UNDO.
    DEF PUBLIC VAR isLoggedIn          	AS LOG INIT FALSE.
    
    DEF VAR sessionFile                 AS CHAR NO-UNDO.
    DEF VAR startDate                   AS DATETIME NO-UNDO.
    DEF VAR request                     AS requestType.
    
    CONSTRUCTOR sessionCore(iRequest AS requestType):
        Parameters = NEW stringArrayType().
        Parameters:parameterDelimiter = CHR(10).
        Parameters:disableUrlEncode   = TRUE.
        
        request    = iRequest.
        request:cSession = this-object.
        
        sessionId = request:cookieParameters:item(sessionCookieName).
        startSession().
    END.
    
    DESTRUCTOR sessionCore():
        DELETE OBJECT Parameters NO-ERROR.
    END.
    
    METHOD PUBLIC CHAR generateSession():
        sessionId = SUBSTRING(encode(guid) + encode(guid) + encode(guid) + encode(guid), 1, 50).
        sessionFile = OS-GETENV("SESSIONS_PATH") + sessionId + ".sid".
        startDate = now.
        
        request:cookieParameters:addItem(sessionCookieName, sessionId).
        Parameters:addItem("startDate", STRING(startDate)).
        
        RETURN sessionId.
    END.
    
    METHOD PUBLIC CHAR startSession():
        DEF VAR content     AS LONGCHAR NO-UNDO.
        
        IF sessionId = "" THEN generateSession().
        
        sessionFile = OS-GETENV("SESSIONS_PATH") + sessionId + ".sid".
        
        IF SEARCH(sessionFile) <> ? THEN 
            DO:
                COPY-LOB FILE sessionFile TO content NO-ERROR.
                Parameters:parseUrl(STRING(content), true).
                startDate = DATETIME(Parameters:item("startDate")) NO-ERROR.
                IF startDate = ? THEN 
                    DO:
                        OS-DELETE sessionFile.
                        sessionId = "".
                        RETURN startSession().
                    END.
                
                isLoggedIn = Parameters:item_logical("isLoggedIn").
            END.
        
        request:cookieParameters:addItem(sessionCookieName, sessionId).
    END.
    
    METHOD PUBLIC CHAR saveSession():
        DEF VAR content AS LONGCHAR NO-UNDO.
        
        content = Parameters:getUrlString().
        Parameters:addItem("isLoggedIn", STRING(isLoggedIn)).
        
        COPY-LOB content TO FILE sessionFile.
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR setLoggedIn(iUserName AS CHAR):
        isLoggedIn = TRUE.
        Parameters:addItem("isLoggedIn", STRING(isLoggedIn)).
        Parameters:addItem("userName", iUserName).
    END.
    
    METHOD PUBLIC CHAR setLoggedOut():
        isLoggedIn = FALSE.
        Parameters:addItem("isLoggedIn", STRING(isLoggedIn)).
        Parameters:addItem("userName", "").
    END.
END.