     DEFINE PUBLIC VARIABLE defaultRootKeyId AS INT64 NO-UNDO INITIAL 1.
     
	 /* Supports key like path [/syste/key/name] */
     METHOD PUBLIC INT64 getKeyId(iKeyName AS CHAR):
        RETURN getKeyId(defaultRootKeyId, iKeyName, 0).
     END.
     METHOD PUBLIC INT64 getKeyId(iParentId AS INT64, iKeyName AS CHAR):
        RETURN getKeyId(iParentId, iKeyName, 0).
     END.
     METHOD PUBLIC INT64 getKeyId(iParentId AS INT64, iKeyName AS CHARACTER, iLevel AS INT):
        DEFINE VARIABLE tCurrentKeyName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tSlashPosition  AS INT64     NO-UNDO.
        DEFINE VARIABLE tRemainingKey   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tCurrentId      AS INT64     NO-UNDO.

        IF iLevel = 0 THEN iKeyName = REPLACE(iKeyName, "\\", "/"). 
        
        tSlashPosition = INDEX(iKeyName, "/").
        
        IF tSlashPosition > 1 THEN 
         DO:
            tCurrentKeyName = SUBSTRING(iKeyName, 1, tSlashPosition - 1).
            tRemainingKey   = SUBSTRING(iKeyName, tSlashPosition + 1).
         END.
        ELSE
         DO:
            tCurrentKeyName = iKeyName.
            tRemainingKey   = "".
         END.
        
        IF tCurrentKeyName = "" THEN
         DO:
            tCurrentId = iParentId.
         END.
        ELSE
         DO:
			/*
            FIND FIRST {&tableName} NO-LOCK WHERE {&tableName}.parent_id  = iParentId 
                                              /*AND {&tableName}.field_name = tCurrentKeyName*/
                                         NO-ERROR.
										 */
            IF NOT AVAILABLE {&tableName} THEN tCurrentId =  -1. ELSE tCurrentId = {&tableName}.id.
         END.
        
        IF tRemainingKey = "" THEN RETURN tCurrentId.
        RETURN getKeyId(tCurrentId, tRemainingKey, iLevel + 1).
     END.

     /* Getting values starting from parent key */
     METHOD PUBLIC CHARACTER getValueChar(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE iKeyId AS INT64 NO-UNDO.
        iKeyId = getKeyId(iParentId, iKeyName).
        FIND FIRST {&tableName} NO-LOCK WHERE {&tableName}.id = iKeyId NO-ERROR.
        IF NOT AVAILABLE {&tableName} THEN RETURN ?.
        RETURN {&tableName}.field_value.
     END.
     METHOD PUBLIC LONGCHAR getValueLongChar(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS LONGCHAR NO-UNDO.
        oValue = getValueChar(iParentId, iKeyName).
        RETURN oValue.
     END.
     METHOD PUBLIC DEC getValueDec(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS DECIMAL NO-UNDO.
        oValue = DECIMAL(getValueChar(iParentId, iKeyName)) NO-ERROR.
        RETURN oValue.
     END.
     METHOD PUBLIC INT64 getValueInt64(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS INT64 NO-UNDO.
        oValue = INT64(getValueChar(iParentId, iKeyName)) NO-ERROR.
        RETURN oValue.
     END.
     METHOD PUBLIC INT getValueInt(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS INT NO-UNDO.
        oValue = INT(getValueChar(iParentId, iKeyName)) NO-ERROR.
        RETURN oValue.
     END.
     METHOD PUBLIC LOG getValueLog(iParentId AS INT64, iKeyName AS CHARACTER):
        RETURN getValueLog(iParentId, iKeyName, "").
     END.
     METHOD PUBLIC LOG getValueLog(iParentId AS INT64, iKeyName AS CHARACTER, iFormat AS CHAR):
        DEFINE VARIABLE oValue AS LOG NO-UNDO.
        /* TODO!
        IF iFormat = "" THEN
            oValue = LOG(getValueChar(iParentId, iKeyName)) NO-ERROR.
		ELSE
            oValue = LOG(getValueChar(iParentId, iKeyName), iFormat) NO-ERROR.
			*/
        RETURN oValue.
     END.
     METHOD PUBLIC DATE getValueDate(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS DATE NO-UNDO.
        oValue = DATE(getValueChar(iParentId, iKeyName)) NO-ERROR.
        RETURN oValue.
     END.
     METHOD PUBLIC DATETIME getValueDatetime(iParentId AS INT64, iKeyName AS CHAR):
        DEFINE VARIABLE oValue AS DATETIME NO-UNDO.
        oValue = DATETIME(getValueChar(iParentId, iKeyName)) NO-ERROR.
        RETURN oValue.
     END.


     /* Getting values starting from root key */
     METHOD PUBLIC CHARACTER getValueChar(iKeyName AS CHAR):
        RETURN getValueChar(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC LONGCHAR getValueLongChar(iKeyName AS CHAR):
        RETURN getValueLongChar(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC DEC getValueDec(iKeyName AS CHAR):
        RETURN getValueDec(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC INT getValueInt(iKeyName AS CHAR):
        RETURN getValueInt(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC INT64 getValueInt64(iKeyName AS CHAR):
        RETURN getValueInt64(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC LOG getValueLog(iKeyName AS CHARACTER):
        RETURN getValueLog(defaultRootKeyId, iKeyName, "").
     END.
     METHOD PUBLIC LOG getValueLog(iKeyName AS CHARACTER, iFormat AS CHAR):
        RETURN getValueLog(defaultRootKeyId, iKeyName, iFormat).
     END.
     METHOD PUBLIC DATE getValueDate(iKeyName AS CHAR):
        RETURN getValueDate(defaultRootKeyId, iKeyName).
     END.
     METHOD PUBLIC DATETIME getValueDatetime(iKeyName AS CHAR):
        RETURN getValueDatetime(defaultRootKeyId, iKeyName).
     END.
