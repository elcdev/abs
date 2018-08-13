CLASS jsonParser:
    DEFINE TEMP-TABLE jsonValues NO-UNDO
        FIELD Id AS INT64
        FIELD ParentId AS INT64
        FIELD KeyParent AS CHARACTER 
        FIELD KeyName   AS CHARACTER
        FIELD KeyValue  AS CLOB
        FIELD ChrValue  AS CHARACTER 
        FIELD KeyType   AS CHARACTER 
        
        INDEX Id Id 
        INDEX ParentId ParentId Id
        INDEX ParentKey ParentId KeyName
        INDEX KeyName KeyName ParentId
        .
    
    METHOD PUBLIC LONGCHAR JsonEncodeValue(val AS LONGCHAR):
        DEFINE VARIABLE returnValue AS LONGCHAR NO-UNDO.
        returnValue = REPLACE(val, '"', '\\"').
        returnValue = REPLACE(returnValue, CHR(10), '\\r').
        returnValue = REPLACE(returnValue, CHR(13), '\\n').
        returnValue = REPLACE(returnValue, CHR(9), '\\t').
        RETURN returnValue.
    END.
    
    METHOD PUBLIC LONGCHAR JsonDecodeValue(val AS LONGCHAR):
        DEFINE VARIABLE returnValue AS LONGCHAR NO-UNDO.
        /* TODO */
        returnValue = val.
        IF INDEX(returnValue, '\\u') > 0 THEN
            returnValue = CONSTRUCTOR:UHEX_TO_CHAR(returnValue, TRUE).
        
        RETURN returnValue.
    END.
    
    METHOD PUBLIC CHARACTER parse(json AS LONGCHAR):
    
    END.
    
    
END CLASS.
    
    
    
    /*
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    DEFINE VARIABLE tJson  AS LONGCHAR NO-UNDO.
    
    METHOD PUBLIC LONGCHAR getResultJson():
        RETURN getResultJson(tJson).
    END.
    
    METHOD PUBLIC LONGCHAR getResultJson(iValue AS LONGCHAR):
        RETURN '\{' + TRIM(iValue, ',') + '\}'.
    END.
    
    METHOD PUBLIC LONGCHAR addValue(iName AS CHARACTER, iValue AS CHARACTER):
        tJson = tJson + jsonValue(iName, iValue, "").
        RETURN "".
    END.
    
    METHOD PUBLIC LONGCHAR addValue(iName AS CHARACTER, iValue AS CHARACTER, iSubArray AS CHARACTER):
        tJson = tJson + jsonValue(iName, iValue, iSubArray).
        RETURN "".
    END.
    
    METHOD PUBLIC LONGCHAR jsonValue(iName AS CHARACTER, iValue AS CHARACTER):
        RETURN jsonValue(iName, iValue, "").
    END.
    
    METHOD PUBLIC LONGCHAR jsonValue(iName AS CHARACTER, iValue AS CHARACTER, iSubArray AS CHARACTER):
        DEFINE VARIABLE tValue AS LONGCHAR NO-UNDO.
        tValue = iValue.
        RETURN jsonValue(iName, tValue, iSubArray).
    END.
    
    METHOD PUBLIC LONGCHAR jsonValue(iName AS CHARACTER, iValue AS LONGCHAR, iSubArray AS CHARACTER):
        IF iSubArray = "" THEN 
         DO:
            RETURN '"' + iName + '":"' + jsonSpecialChars(iValue) + '",'.
         END.
         
        RETURN '"' + iName + '":\{' + TRIM(iValue, ',') + '\},'.
    END.
    
    METHOD PUBLIC CHARACTER toHex(iValue AS INTEGER, iLength AS INT):
        DEFINE VARIABLE rw AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE ch AS CHARACTER NO-UNDO.

        SET-BYTE-ORDER(rw) = 2.
        SET-SIZE(rw) = 4.
        PUT-LONG(rw,1) = iValue.
        ch = HEX-ENCODE(rw).
        IF iLength > 0 AND LENGTH(ch) > iLength THEN ch = SUBSTRING(ch, LENGTH(ch) - iLength + 1).
        
        RETURN ch.
    END.
    
    METHOD CHARACTER jsonSpecialChars(iValue AS CHARACTER):
        DEFINE VARIABLE tValue  AS LONGCHAR  NO-UNDO.
        tValue = iValue.
        RETURN STRING(jsonSpecialChars(tValue)).
    END.
    
    METHOD LONGCHAR jsonSpecialChars(iValue AS LONGCHAR):
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE c       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oValue  AS LONGCHAR  NO-UNDO.
        
        DO i = 1 TO LENGTH(iValue):
            c = SUBSTRING(iValue, i, 1).
            IF ASC(c) < 32 THEN oValue = oValue + '\\u' + toHex(ASC(c), 4).
            IF c = '"'     THEN oValue = oValue + '\\"'.
            IF c = '\\'    THEN oValue = oValue + '\\\\'.
            IF c = '/'     THEN oValue = oValue + '\\/'.
            IF c = CHR(13) THEN oValue = oValue + '\\n'.
            IF c = CHR(10) THEN oValue = oValue + '\\r'.
            IF c = CHR(9)  THEN oValue = oValue + '\\t'.
            IF c = '\{'    THEN oValue = oValue + '\\u' + toHex(ASC(c), 4).
            IF c = '\}'    THEN oValue = oValue + '\\u' + toHex(ASC(c), 4).
        END.        
        
        RETURN oValue.
    END.
    
    
END CLASS.
*/