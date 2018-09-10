        DEFINE BUFFER {&table} FOR {&table}.
        
        FIND FIRST {&table} NO-LOCK WHERE {&table}.{&field} = i{&field} NO-ERROR.
        IF NOT AVAILABLE {&table} THEN RETURN "RECORD-NOT-FOUND".
		
		id      = {&table}.id.
		version = {&table}.version.
