CLASS jsonMaker:
    DEFINE VARIABLE tJson  AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE openTag AS CHAR NO-UNDO.
    DEFINE VARIABLE closeTag AS CHAR NO-UNDO.
    
    CONSTRUCTOR jsonMaker():
        openTag  = CHR(123).
        closeTag = CHR(125).
    END.
    
    METHOD PUBLIC LONGCHAR getResultJson():
        RETURN getResultJson(tJson).
    END.
    
    METHOD PUBLIC LONGCHAR getResultJson(iValue AS LONGCHAR):
        RETURN openTag + TRIM(iValue, ',') + closeTag.
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
         
        RETURN '"' + iName + '":' + openTag + TRIM(iValue, ',') + closeTag + ','.
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
            IF c = openTag THEN oValue = oValue + '\\u' + toHex(ASC(c), 4).
            IF c = closeTag THEN oValue = oValue + '\\u' + toHex(ASC(c), 4).
        END.        
        
        RETURN oValue.
    END.
    
    
END CLASS.
