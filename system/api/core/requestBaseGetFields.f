        DEFINE BUFFER {1} FOR {1}.
        
        FIND FIRST {1} NO-LOCK WHERE {1}.id = iId NO-ERROR.
        IF NOT AVAILABLE {1} THEN RETURN "RECORD-NOT-FOUND".
		
		id      = {1}.id.
		version = {1}.version.
