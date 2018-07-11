CLASS webSlugType INHERITS webType:
    DEF PUBLIC VAR slug   AS CHAR NO-UNDO.
    DEF PUBLIC VAR token  AS CHAR NO-UNDO.
    DEF PUBLIC VAR name   AS CHAR NO-UNDO.
    DEF PUBLIC VAR action AS CHAR NO-UNDO.
    DEF PUBLIC VAR api    AS CHAR NO-UNDO.
    DEF PUBLIC VAR https  AS CHAR NO-UNDO.
    DEF PUBLIC VAR host   AS CHAR NO-UNDO.
    
    DEF PUBLIC VAR postData 		AS CHAR NO-UNDO.
    DEF PUBLIC VAR getData  		AS CHAR NO-UNDO.

    DEF PUBLIC VAR url              AS CHAR.
    DEF PUBLIC VAR getParameters    AS stringArrayType.
    DEF PUBLIC VAR postParameters   AS stringArrayType.
    DEF PUBLIC VAR cookieParameters AS stringArrayType.
    DEF PUBLIC VAR cSession         AS sessionCore  NO-UNDO.
    
    CONSTRUCTOR webSlugType():
        DEF VAR iUrl AS CHAR.

        getParameters    = NEW stringArrayType().
        postParameters   = NEW stringArrayType().
        cookieParameters = NEW stringArrayType().
        
		iUrl = OS-GETENV("REQUEST_URI").
        parseSlug(iUrl).
    END.

    CONSTRUCTOR webSlugType(iSlug AS CHAR):
        parseSlug(iSlug).
    END.
    

    METHOD PUBLIC CHAR Empty():
	    token = "".
	    name  = "".
	    action = "".
    END.

    METHOD PUBLIC CHAR parseSlug(iSlug AS CHAR):
        DEF VAR tItem     AS CHAR.
        DEF VAR tItemData AS LONGCHAR NO-UNDO.
	    Empty().
	    slug    = iSlug.

	    url            = ENTRY(1, iSlug, "?") NO-ERROR.

	    tItemData = OS-GETENV("HTTP_COOKIE").
	    cookieParameters:parameterDelimiter = ";".
	    cookieParameters:parseUrl(STRING(tItemData), TRUE).

	    tItem = ENTRY(2, iSlug, "?") NO-ERROR.
   	    getParameters:parseUrl(tItem, TRUE).
	    getData = tItem.

	    tItemData = OS-GETENV("POSTDATA").
	    postParameters:parseUrl(STRING(tItemData), TRUE).
	    postData = STRING(tItemData).

	    https   = OS-GETENV("REQUEST_SCHEME").
        host    = OS-GETENV("HTTP_HOST").
	    api     = ENTRY(2, iSlug, "/") NO-ERROR.
	    name    = ENTRY(3, iSlug, "/") NO-ERROR.
	    action  = ENTRY(4, iSlug, "/") NO-ERROR.
	    token   = ENTRY(5, iSlug, "/") NO-ERROR.
	    
	    RETURN "".
    END.

    METHOD PUBLIC CHAR b64Decode (iStr AS CHAR):
        DEFINE VARIABLE decdmptr AS MEMPTR   NO-UNDO.
        decdmptr = BASE64-DECODE(getParameters:urlDecode(iStr)).
        
        RETURN get-string(decdmptr, 1).
    END.
    
    
    METHOD PUBLIC CHAR getUrl():
        DEF VAR tUrl AS CHAR.
        DEF VAR tGet AS CHAR.
        
        tUrl =  https + '//' + host + '/' + api + '/' + name + '/' + action + '/' + token.
        tGet = getParameters:getUrlString().
        IF tGet <> "" THEN tUrl = tUrl + "?" + tGet.
        
        RETURN tUrl.
    END.
END.

