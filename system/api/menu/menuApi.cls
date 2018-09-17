CLASS menuApi INHERITS apiBase:
    {menuTable.i &formTable="formTable"}
    {menuEditTable.i &formTable="formEditTable" /*&reference = "REFERENCE-ONLY"*/}

    METHOD PUBLIC CHARACTER getData (parent_id AS INT64, INPUT-OUTPUT TABLE formTable):
        DEFINE BUFFER menu FOR menu.
        
        EMPTY TEMP-TABLE formTable.
        
        FOR EACH menu NO-LOCK WHERE menu.parent_id = parent_id:
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
        END.
        
        RETURN "".
    END.
 
    METHOD PUBLIC CHARACTER getItemData (iId AS INT64, INPUT-OUTPUT TABLE formEditTable):
        RETURN getItemData (iId, "menu", INPUT-OUTPUT TABLE formEditTable).
    END.
    
    METHOD PUBLIC CHARACTER getItemData (iId AS INT64, iTableName AS CHARACTER, INPUT-OUTPUT TABLE formEditTable):
        EMPTY TEMP-TABLE formEditTable.
        
        DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
        DEFINE VARIABLE hQuery  AS HANDLE NO-UNDO.
        DEFINE VARIABLE i       AS INT64  NO-UNDO.
        
        CREATE BUFFER hBuffer FOR TABLE iTableName.
        CREATE QUERY hQuery.

        hQuery:SET-BUFFERS(hBuffer).
        hQuery:QUERY-PREPARE("FOR EACH " + iTableName + " WHERE id = " + STRING(iId)).
        hQuery:QUERY-OPEN().
        hQuery:GET-FIRST().
        
        IF NOT hQuery:QUERY-OFF-END THEN
         DO:
            addPropertyItem(iId, hBuffer).
         END.
        
        hQuery:QUERY-CLOSE().
        hBuffer:BUFFER-RELEASE().
        DELETE OBJECT hBuffer.
        DELETE OBJECT hQuery.
        
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER addPropertyItem(iId AS INT64, hBuffer AS HANDLE):
        DEFINE VARIABLE i      AS INT64  NO-UNDO INITIAL 0.   
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.
        
        DO i = 1 TO hBuffer:NUM-FIELDS:
            hField = hBuffer:BUFFER-FIELD(i).
            IF INDEX("id;updateCount;version;state;modify_date;modify_user;create_date;create_user;parent_id;", hField:NAME + ";") > 0 THEN NEXT.
            /* 
            TODO!
            IF NOT hField:COLUMN-LABEL BEGINS "formItem" THEN NEXT.
            */

            CREATE formEditTable.
            ASSIGN
            formEditTable.id            = iId
            formEditTable.fieldValue    = STRING(hField:BUFFER-VALUE)
            formEditTable.fieldName     = hField:NAME
            formEditTable.fieldLabel    = hField:LABEL
            formEditTable.fieldPosition = hField:POSITION
            formEditTable.fieldType     = hField:DATA-TYPE
            .
        END.
        
        RETURN "".
    END.

    METHOD PUBLIC CHARACTER getData (searchString AS CHAR, iTop AS INT64, INPUT-OUTPUT TABLE formTable):
        DEFINE BUFFER menu FOR menu.
        
        EMPTY TEMP-TABLE formTable.
        
        FOR EACH menu NO-LOCK WHERE menu.function_name MATCHES "*" + searchString + "*":
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
            i = i + 1.
            IF i > iTop AND iTop > 0 THEN LEAVE.
        END.

        FOR EACH menu NO-LOCK WHERE menu.description MATCHES "*" + searchString + "*":
            CREATE formTable.
            BUFFER-COPY menu TO formTable.
            i = i + 1.
            IF i > iTop AND iTop > 0 THEN LEAVE.
        END.
        
        RETURN "".
    END.
    
    METHOD PUBLIC LOG existsMenuItem(iId AS INT64):
        DEFINE BUFFER menu FOR menu.

        FOR EACH menu NO-LOCK WHERE menu.id = iId USE-INDEX id:
            RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.
    
    METHOD PUBLIC LOG existsMenuItem(iFunction AS CHAR):
        DEFINE BUFFER menu FOR menu.

        FOR EACH menu NO-LOCK WHERE menu.function_name = iFunction USE-INDEX function_name:
            RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.
    
    METHOD PUBLIC menuItemModel getModel(iId AS INT64):
        RETURN getMenuItem(iId).
    END.
    
    METHOD PUBLIC menuItemModel getMenuItem(iId AS INT64):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iId) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iId).
        garbage:addItem(tMenu).
        
        RETURN tMenu.
    END.

    METHOD PUBLIC menuItemModel getMenuItem(iFunction AS CHAR):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        
        IF NOT existsMenuItem(iFunction) THEN RETURN ?.
        
        tMenu = NEW menuItemModel().
        tMenu:getDb(iFunction).
        garbage:addItem(tMenu).
        
        RETURN tMenu.
    END.
    
    METHOD PUBLIC CHARACTER setValuesFromEditBuffer(iId AS INT64, INPUT-OUTPUT TABLE formEditTable):
        DEFINE VARIABLE tMenu AS menuItemModel NO-UNDO.
        DEFINE VARIABLE oError AS CHARACTER INITIAL "ERROR".
        
        tMenu = getModel(iId).
        
        FOR EACH formEditTable WHERE formEditTable.id = iId:
            oError = "".

            CASE formEditTable.fieldType:
                WHEN "CHAR" OR WHEN "CHARACTER" THEN
                 DO:
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = formEditTable.fieldValue.
                 END.
                WHEN "DATE" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = DATE(formEditTable.fieldValue) NO-ERROR.
                WHEN "DATETIME" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = DATETIME(formEditTable.fieldValue) NO-ERROR.
                WHEN "LOG" OR WHEN "LOGICAL" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = formEditTable.fieldValue NO-ERROR.
                WHEN "INT" OR WHEN "INTEGER" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = INT(formEditTable.fieldValue) NO-ERROR.
                WHEN "INT64" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = INT64(formEditTable.fieldValue) NO-ERROR.
                WHEN "DEC" OR WHEN "DECIMAL" THEN
                    DYNAMIC-PROPERTY(tMenu, formEditTable.fieldName) = DEC(formEditTable.fieldValue) NO-ERROR.
                OTHERWISE 
                    RETURN "UNSUPPORTED-DATA-TYPE: setValuesFromEditBuffer".
            END.
        END.

        RETURN tMenu:putDb().
    END.

END CLASS.