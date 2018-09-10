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
                        RETURN "ERROR-SET-VALUE-FROM-BUFFER:" + eAnyError:GetMessage(1).
                    END CATCH.

                 END.
            END.
        END.
        
        RETURN  "".
    END.
    
    METHOD CHARACTER getUser():
    
    END.
END CLASS.