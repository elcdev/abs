CLASS stringArrayType:
    DEF PUBLIC VAR parameterDelimiter AS CHAR INIT "&".
    DEF PUBLIC VAR disableUrlEncode   AS LOG  INIT FALSE.

    DEF TEMP-TABLE tmpTab NO-UNDO
        FIELD name AS CHAR
        FIELD val  AS CHAR
        INDEX name name
        .
    
    CONSTRUCTOR stringArrayType():
    
    END.

    CONSTRUCTOR stringArrayType(iString AS CHAR, iUrlDecode AS LOG):
        parseUrl(iString, iUrlDecode).
    END.
        
    METHOD PUBLIC CHAR addItem(iName AS CHAR, iValue AS CHAR):
        IF iName = "" OR iName = ? THEN RETURN "INVALID_NAME".
        iName = TRIM(iName).

        FIND FIRST tmpTab WHERE tmpTab.name = iName NO-ERROR.
        IF NOT AVAILABLE tmpTab THEN CREATE tmpTab.
        tmpTab.name = iName.
        tmpTab.val  = iValue.
        
        RETURN "".
    END.

    METHOD PUBLIC CHAR item(iName AS CHAR):
        FIND FIRST tmpTab WHERE tmpTab.name = iName NO-ERROR.
        IF NOT AVAILABLE tmpTab THEN RETURN "".
        RETURN tmpTab.Val.
    END.
    
    METHOD PUBLIC LOG item_logical(iName AS CHAR):
        DEFINE VARIABLE oVal AS LOGICAL NO-UNDO.
        oVal = LOGICAL(item(iName)) NO-ERROR.
        IF oVal = ? THEN RETURN FALSE.
        RETURN oVal.
    END.
    
    METHOD PUBLIC CHAR parseUrl(iString AS CHAR, iUrlDecode AS LOG):
        DEF VAR tIndex  AS INT64 NO-UNDO.
        DEF VAR tName  AS CHAR  NO-UNDO.
        DEF VAR tValue AS CHAR  NO-UNDO.
        
		IF iString = ? THEN RETURN "".
		
        DO tIndex = 1 TO NUM-ENTRIES(iString, parameterDelimiter):
            tName = "".
            tValue = "".

            tName  = ENTRY(tIndex, iString, parameterDelimiter) NO-ERROR.
            IF tName = "" THEN NEXT.
            
            tValue = ENTRY(2, tName, "=") NO-ERROR. 
            tName  = ENTRY(1, tName, "=") NO-ERROR.
            IF tName = "" THEN NEXT.
            
            IF iUrlDecode THEN
             DO:
                tValue = UrlDecode(tValue).
                tName  = UrlDecode(tName).
             END.
            
            addItem(tName, tValue).
        END.
		
		RETURN "".
    END.
    
    METHOD PUBLIC CHAR urlDecode (iUrl AS CHAR):
        iUrl = REPLACE(iUrl, "%3A", ":").
        iUrl = REPLACE(iUrl, "%2F", "/").
        iUrl = REPLACE(iUrl, "%3F", "?").
        iUrl = REPLACE(iUrl, "%40", "@").
        iUrl = REPLACE(iUrl, "%26", "&").
        iUrl = REPLACE(iUrl, "%3D", "=").
        iUrl = REPLACE(iUrl, "%25", "%").
        iUrl = REPLACE(iUrl, "%20", " ").
        iUrl = REPLACE(iUrl, "+",   " ").
        iUrl = REPLACE(iUrl, "%23",   "#").
        iUrl = REPLACE(iUrl, "%3B",   ";").
        
        RETURN iUrl.
    END.

    METHOD PUBLIC CHAR urlEncode (iUrl AS CHAR):
	IF disableUrlEncode THEN RETURN iUrl.

        iUrl = REPLACE(iUrl, "%", "%25").
        
        iUrl = REPLACE(iUrl, ":", "%3A").
        iUrl = REPLACE(iUrl, "/", "%2F").
        iUrl = REPLACE(iUrl, "?", "%3F").
        iUrl = REPLACE(iUrl, "@", "%40").
        iUrl = REPLACE(iUrl, "&", "%26").
        iUrl = REPLACE(iUrl, "=", "%3D").
        iUrl = REPLACE(iUrl, " ", "%20").
        iUrl = REPLACE(iUrl, "#", "%23").
        iUrl = REPLACE(iUrl, ";", "%3B").
        
        RETURN iUrl.
    END.
    
    METHOD PUBLIC CHAR getCookies():
	RETURN getUrlString("Set-Cookie: ", CHR(10), "; HttpOnly; Max-Age=10000; Path=/;").
    END.

    METHOD PUBLIC CHAR getUrlString ():
	RETURN getUrlString ("", parameterDelimiter, "").
    END.

    METHOD PUBLIC CHAR getUrlString (iPrefix AS CHAR, iVarDelimiter AS CHAR, iSufix AS CHAR):
        DEF VAR tResponse AS CHAR NO-UNDO INIT "".

        FOR EACH tmpTab WHERE tmpTab.name <> "":
            tResponse = tResponse + iPrefix + urlEncode(tmpTab.Name) + "=" + urlEncode(tmpTab.Val) + iSufix + iVarDelimiter.
        END.

        RETURN tResponse.
    END.

END.
