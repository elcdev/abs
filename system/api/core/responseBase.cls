CLASS responseBase IMPLEMENTS responseInterface:
    DEFINE PUBLIC VARIABLE state            AS CHARACTER NO-UNDO.

    DEFINE PUBLIC VARIABLE errorDescription AS CHARACTER NO-UNDO.
    DEFINE PUBLIC VARIABLE infoDescription  AS CHARACTER NO-UNDO.
    DEFINE PUBLIC VARIABLE jsonData         AS LONGCHAR  NO-UNDO.
    
    DEFINE VARIABLE cJsonMaker              AS jsonMaker NO-UNDO.
    
    CONSTRUCTOR responseBase():
        cJsonMaker = NEW jsonMaker().
    END.
    
    DESTRUCTOR responseBase():
        DELETE OBJECT cJsonMaker NO-ERROR.
    END.
    
    METHOD PUBLIC LONGCHAR getJson():
        DEFINE VARIABLE json AS LONGCHAR NO-UNDO.

        json = cJsonMaker:jsonValue("state", state).
        json = json + cJsonMaker:jsonValue("errorDescription", errorDescription).
        json = json + cJsonMaker:jsonValue("infoDescription", errorDescription).
        json = cJsonMaker:jsonValue("responseBase", json, "object").
        
        RETURN cJsonMaker:getResultJson(json).
    END.
    
END CLASS.