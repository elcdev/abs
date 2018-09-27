        DEF VAR oError AS CHAR NO-UNDO.
		DEFINE BUFFER {&table} FOR {&table}.
        
		oError = prepare().
		IF oError <> "" THEN RETURN oError.
		
		IF id > 0 THEN
		 DO:
			FIND FIRST {&table} NO-LOCK WHERE {&table}.id = id NO-ERROR.
			IF NOT AVAILABLE {&table} THEN RETURN "RECORD-NOT-FOUND".
			FIND FIRST {&table} WHERE {&table}.id = id EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
			IF NOT AVAILABLE {&table} THEN RETURN "RECORD-LOCKED".
		 END.
		ELSE
		 DO:
			CREATE {&table}.
			{&table}.create_user      = globalSettings:loginName. 
			{&table}.create_date      = now.
			id                        = {&table}.id.
			version                   = {&table}.version.
		 END.
		
		{&table}.modify_user = globalSettings:loginName. 
		{&table}.modify_date = now.

