        DEFINE BUFFER {1} FOR {1}.
        
		IF iId > 0 THEN
		 DO:
			FIND FIRST {1} NO-LOCK WHERE {1}.id = iId NO-ERROR.
			IF NOT AVAILABLE {1} THEN RETURN "RECORD-NOT-FOUND".
		 END.
		ELSE
		 DO:
			CREATE {1}.
		 END.
		
		{1}.id      = id.
		{1}.version = version.
