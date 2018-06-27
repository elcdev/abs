CLASS responseType:
    DEF PUBLIC VAR contentType AS CHAR      NO-UNDO INIT "text/html".
    DEF PUBLIC VAR content     AS LONGCHAR  NO-UNDO.
    DEF PUBLIC VAR errors      AS errorType NO-UNDO.
    DEF PUBLIC VAR isError     AS LOG       NO-UNDO.
    
    CONSTRUCTOR responseType():
        errors = NEW errorType().
    END.
    
    DESTRUCTOR responseType():
        DELETE OBJECT errors NO-ERROR.
    END.
    
    METHOD PUBLIC CHAR setVar(iName AS CHAR, iValue AS CHAR):
        content = REPLACE(content, "[" + iName + "]", iValue).
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR setVar(iName AS CHAR, iValue AS responseType):
        content = REPLACE(content, "[" + iName + "]", iValue:content).
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR setByPostVar(iName AS CHAR, iRequest AS requestType):
        content = REPLACE(content, "[" + iName + "]", iRequest:postParameters:item(iName)).
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR setByGetVar(iName AS CHAR, iRequest AS requestType):
        content = REPLACE(content, "[" + iName + "]", iRequest:getParameters:item(iName)).
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR loadTemplate(iFileName AS CHAR):
        iFileName = TRIM(iFileName).
        
        IF SEARCH(iFileName) = ? THEN
         DO:
            content = "<h5>Template: " + iFileName + " not found!</h5>" .
            RETURN "FILE-NOT-FOUND".
         END.
        
        COPY-LOB FILE SEARCH(iFileName) TO content.
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR redirect(iUrl AS CHAR):
        contentType = "Location".
        content = iUrl.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR setError(iError AS CHAR):
        IF iError <> "" THEN isError = TRUE. ELSE isError = FALSE.
        errors:errorDescription = iError.
    END.
    
    METHOD PUBLIC CHAR getError():
        RETURN errors:errorDescription.
    END.
    
    METHOD CHAR getErrorHtml(iTemplate AS CHAR):
        IF iTemplate = "" THEN iTemplate = '<h1 class="h5 mb-5 font-weight-normal text-danger">[error]</h1>'.
        RETURN REPLACE(iTemplate, "[error]", errors:errorDescription).
    END.
    
    METHOD PUBLIC CHAR processError():
        IF isError THEN RETURN	setVar("error", getErrorHtml("")).
        RETURN setVar("error", "").
    END.
END.
