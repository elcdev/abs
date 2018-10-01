        DEFINE BUFFER {&table} FOR {&table}.
        
        FIND FIRST {&table} NO-LOCK WHERE {&table}.{&field} = i{&field} 
		and {&table}.{&field2} = i{&field2} and {&table}.state <> 9 NO-ERROR.
        IF NOT AVAILABLE {&table} THEN RETURN "RECORD-NOT-FOUND".
		
		id      = {&table}.id.
		version = {&table}.version.
