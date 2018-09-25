    METHOD PUBLIC {&override} STATIC {&class} parseJsonFile(iJsonFile AS CHAR):
        RETURN CAST (fromJsonFile(iJsonFile, "{&class}"), {&class}).
    END.
    
    METHOD PUBLIC {&override} STATIC {&class} parseJson(iJson AS LONGCHAR):
        RETURN CAST (fromJson(iJson, "{&class}"), {&class}).
    END.
	
	METHOD PUBLIC VOID toJsonFile(iJsonFile AS CHARACTER):
		DEF VAR oJson AS LONGCHAR NO-UNDO.
		
		oJson = toJson().
		
		COPY-LOB oJson TO FILE iJsonFile.
	END.