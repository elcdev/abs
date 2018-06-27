CLASS menuRequest inherits requestBase IMPLEMENTS dbInterface:
	DEF VAR id            AS INT.
	DEF VAR version       AS INT.
    DEF VAR position      AS INT.
	DEF VAR functionName  AS CHAR.
	DEF VAR procedureName AS CHAR.
	DEF VAR slug          AS CHAR.
	DEF VAR description   AS CHAR.
	
	METHOD PUBLIC CHARACTER putDb():
	
	END.
	
	METHOD PUBLIC CHARACTER getDb(iId AS INT):
	
	END.
	
	METHOD PUBLIC CHARACTER getJson():
	
	END.
	
END CLASS.