CLASS dbModel IMPLEMENTS dbInterface:
    {propertyGetSet.f &name="action"  &type="char"}
    {propertyGetSet.f &name="id"      &type="int64"}
    {propertyGetSet.f &name="version" &type="int64"}

    METHOD PUBLIC CHARACTER getDb(iId AS INT64):
        RETURN "NOT-EMPLEMENTED".
    END.
    METHOD PUBLIC CHARACTER putDb():
        RETURN "NOT-EMPLEMENTED".
    END.
    METHOD PUBLIC CHARACTER getJson():
        RETURN "NOT-EMPLEMENTED".
    END.
    

    METHOD PUBLIC CHARACTER getValuesFromBuffer(hBuffer AS HANDLE):
        DEFINE VARIABLE oProperties AS Progress.Reflect.Property NO-UNDO EXTENT.
        DEFINE VARIABLE hField      AS HANDLE NO-UNDO.
        DEFINE VARIABLE i           AS INTEGER NO-UNDO.
        
        IF NOT VALID-HANDLE(hBuffer) THEN RETURN "ERROR-INVALID-BUFFER-HANDLE". 
        
        oProperties = THIS-OBJECT:GetClass():GetProperties() . 
         
        DO i = 1 TO EXTENT(oProperties):
            IF oProperties[i]:DataTypeName <> "Progress.Lang.Object" THEN
            DO:
                hField = hBuffer:BUFFER-FIELD(oProperties[i]:NAME) NO-ERROR.
                IF VALID-HANDLE(hField) THEN 
                 DO ON ERROR UNDO, THROW:
                    DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = hField:BUFFER-VALUE().

                    CATCH eAnyError AS Progress.Lang.Error:
                        RETURN "ERROR-SET-VALUE-FROM-BUFFER:" + eAnyError:GetMessage(1).
                    END CATCH.

                 END.
            END.
        END.
        
        RETURN  "".
    END.
    
    METHOD PUBLIC CHARACTER setValuesToBuffer(hBuffer AS HANDLE):
        DEFINE VARIABLE oProperties AS Progress.Reflect.Property NO-UNDO EXTENT.
        DEFINE VARIABLE hField      AS HANDLE NO-UNDO.
        DEFINE VARIABLE i           AS INTEGER NO-UNDO.
        DEFINE VARIABLE tString     AS CHARACTER NO-UNDO. 
        
        IF NOT VALID-HANDLE(hBuffer) THEN RETURN "ERROR-INVALID-BUFFER-HANDLE".
        
        oProperties = THIS-OBJECT:GetClass():GetProperties() . 
         
        DO i = 1 TO EXTENT(oProperties):
            IF oProperties[i]:DataTypeName <> "Progress.Lang.Object" THEN
            DO:
                hField = hBuffer:BUFFER-FIELD(oProperties[i]:NAME) NO-ERROR.
                
                IF VALID-HANDLE(hField) THEN 
                 DO ON ERROR UNDO, THROW:
                    hField:BUFFER-VALUE() = DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME).

                    CATCH eAnyError AS Progress.Lang.Error:
                        tString = STRING(DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME)).
                        RETURN "ERROR-SET-VALUE-TO-BUFFER: " + oProperties[i]:NAME + "=" + STRING(tString, "X(20)") + "; " + eAnyError:GetMessage(1).
                    END CATCH.

                 END.
            END.
        END.
        
        RETURN  "".
    END.
    
    METHOD PUBLIC CHARACTER empty():
        DEFINE VARIABLE oProperties AS Progress.Reflect.Property NO-UNDO EXTENT.
        DEFINE VARIABLE i           AS INTEGER NO-UNDO.
        DEFINE VARIABLE tString     AS CHARACTER NO-UNDO. 

        oProperties = THIS-OBJECT:GetClass():GetProperties() . 
         
        DO i = 1 TO EXTENT(oProperties):
            IF oProperties[i]:DataTypeName <> "Progress.Lang.Object" THEN
             DO ON ERROR UNDO, THROW:
                CASE oProperties[i]:DataTypeName:
                    WHEN "INTEGER"   THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = 0.
                    WHEN "INT64"     THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = 0.
                    WHEN "DECIMAL"   THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = 0.
                    WHEN "CHARACTER" THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = "".
                    WHEN "LONGCHAR"  THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = "".
                    WHEN "LOGICAL"   THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = FALSE.
                    WHEN "DATE"      THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = ?.
                    WHEN "DATETIME"  THEN DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = ?.
                    OTHERWISE             DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME) = ?.
                 END.
                CATCH eAnyError AS Progress.Lang.Error:
                    tString = STRING(DYNAMIC-PROPERTY(THIS-OBJECT, oProperties[i]:NAME)).
                    RETURN "ERROR-IN-EMPTY-MODEL: Field=" + oProperties[i]:NAME + "; " + eAnyError:GetMessage(1).
                END CATCH.
             END.
        END.
        
        RETURN  "".
    END.

    
END CLASS.