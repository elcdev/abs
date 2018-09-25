USING system.api.systemSettings.*.
USING system.api.core.*.

CLASS system.api.systemSettings.databaseConnections SERIALIZABLE INHERITS dbModel:
    DEFINE VARIABLE settingsFileName AS CHARACTER INITIAL "config/db.conf".
    
    DEFINE STATIC TEMP-TABLE db NO-UNDO 
        FIELD connectionName    AS CHARACTER 
        FIELD logicalName       AS CHARACTER 
        FIELD phisicalName      AS CHARACTER 
        FIELD host              AS CHARACTER
        FIELD port              AS CHARACTER
        FIELD connectionString  AS CHARACTER 
        
        INDEX connectionName 
            AS UNIQUE
            connectionName
        .

    CONSTRUCTOR databaseConnections():
        IF SEARCH(settingsFileName) <> ? THEN settingsFileName = SEARCH(settingsFileName).
        loadSettings().
    END.
    
    METHOD PUBLIC CHARACTER addItem(iConnectionName     AS CHARACTER,
                                    iLogicalName        AS CHARACTER,
                                    iPhisicalName       AS CHARACTER, 
                                    iHost               AS CHARACTER,
                                    iPort               AS CHARACTER,
                                    iConnectionString   AS CHARACTER 
                                    ):
        FIND FIRST db WHERE db.ConnectionName   = iConnectionName NO-ERROR.
        IF NOT AVAILABLE db THEN CREATE db.
        
        ASSIGN
            db.ConnectionName   = iConnectionName
            db.logicalName      = iLogicalName
            db.phisicalName     = iPhisicalName
            db.host             = iHost
            db.port             = iPort
            db.connectionString = iConnectionString
            .
            
        RETURN "".
    END.

    METHOD STATIC PUBLIC CHARACTER getConnectionString(iConnectionName     AS CHARACTER):
        DO ON ERROR UNDO, THROW:
            FIND FIRST db WHERE db.ConnectionName   = iConnectionName NO-ERROR.

            IF NOT AVAILABLE db THEN 
                UNDO, THROW NEW Progress.Lang.AppError("ERROR-CONNECTION-NOT-FOUND,ConnectionName:" + iConnectionName, 200).
        END.
        FINALLY:
            IF AVAILABLE db THEN RETURN db.connectionString .
            RETURN "".
        END.
    END.
    
    METHOD PUBLIC CHARACTER saveSettings():
        DEFINE VARIABLE hDb AS HANDLE.
        
        hDb = TEMP-TABLE db:HANDLE.
        hDb:WRITE-JSON("FILE", settingsFileName, TRUE, "utf-8").
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER loadSettings():
        DEFINE VARIABLE hDb AS HANDLE.
        
        hDb = TEMP-TABLE db:HANDLE.
        hDb:READ-JSON("FILE", settingsFileName, "REPLACE").
        
        RETURN "".
    END.
END.