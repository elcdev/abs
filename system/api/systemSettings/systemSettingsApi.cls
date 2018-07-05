CLASS systemSettingsApi INHERITS apiBase:

     METHOD PUBLIC OVERRIDE responseBase invoke(request AS requestBase).
        CASE request:action:
            WHEN "getdb"   THEN 
             DO:
                response:errorDescription = request:getDb().
                response:data = request.
             END.
            WHEN "putdb"   THEN response:errorDescription = request:putDb().
            WHEN "getjson" THEN 
             DO:
                response:errorDescription = request:getDb().
                response:data = request.
             END.
        END.
        
        RETURN response.
     END.

END CLASS.