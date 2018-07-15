CLASS menuApi INHERITS apiBase:
    {menuTable.i}
	
    METHOD PUBLIC OVERRIDE responseBase invoke(request AS requestBase).
        CASE request:action:
            WHEN "getdb"   THEN response:errorDescription = request:getDb().
            WHEN "putdb"   THEN response:errorDescription = request:putDb().
            WHEN "getjson" THEN response:jsonData         = request:getJson().
        END.
        
        RETURN response.
    END.

	METHOD PUBLIC CHARACTER getData():
	 
	END.
	 
END CLASS.