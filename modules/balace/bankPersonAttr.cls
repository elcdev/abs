CLASS bankPersonAttr:
    DEF PUBLIC VAR cBPerson AS bankPerson NO-UNDO.
    CONSTRUCTOR bankPersonAttr(pBPerson AS bankPerson):
        cBPerson = pBPerson.
    END.
    
    METHOD PUBLIC CHAR Item(p_FieldName AS CHAR, p_FieldSource AS CHAR):
        RETURN Item( cBPerson:Id, p_FieldName, p_FieldSource).
    END.
    METHOD PUBLIC CHAR Item(p_Person_Id AS INT64, p_FieldName AS CHAR, p_FieldSource AS CHAR):
        DEF BUFFER ALL_Person_Attr FOR ALL_Person_Attr.
        FIND FIRST ALL_Person_Attr NO-LOCK WHERE ALL_Person_Attr.Person_Id   = p_Person_Id 
                                             AND ALL_Person_Attr.FieldSource = p_FieldSource
                                             AND ALL_Person_Attr.FieldName   = p_FieldName
                                            NO-ERROR.
        IF AVAILABLE ALL_Person_Attr THEN
         DO:
            RETURN ALL_Person_Attr.FieldValue.
         END.
        RETURN "".
    END.
    METHOD PUBLIC INT64 Item_Int(p_Id AS INT64, p_FieldName AS CHAR, p_FieldSource AS CHAR):
        RETURN INT64(Item(p_Id, p_FieldName, p_FieldSource)).
    END.
    METHOD PUBLIC DATE Item_Dat(p_Id AS INT64, p_FieldName AS CHAR, p_FieldSource AS CHAR):
        RETURN DATE(Item(p_Id, p_FieldName, p_FieldSource)).
    END.
    METHOD PUBLIC LOGICAL Item_Log(p_Id AS INT64, p_FieldName AS CHAR, p_FieldSource AS CHAR):
        RETURN LOGICAL(Item(p_Id, p_FieldName, p_FieldSource)).
    END.
      
    METHOD PUBLIC CHAR Item(p_FieldName AS CHAR):
        RETURN Item(p_FieldName, "").
    END.
    
    METHOD PUBLIC CHAR SetItem(iPersonId AS INT64, iFieldName AS CHAR, iFieldValue AS CHAR, iFieldSource AS CHAR):
        DEF BUFFER ALL_Person_Attr FOR ALL_Person_Attr.
        IF iPersonId < 1 THEN
         DO:
            MESSAGE "PersonId INCORRECT! DATA NOT SAVED! " cBPerson:firstName cBPerson:lastName.
            PAUSE 3.
            RETURN "PERSONID_INCORRECT".
         END.
        FIND FIRST ALL_Person_Attr WHERE ALL_Person_Attr.Person_Id    = iPersonId
                                      AND ALL_Person_Attr.FieldName   = iFieldName
                                      AND ALL_Person_Attr.FieldSource = iFieldSource
                                     NO-ERROR.
        IF NOT AVAILABLE ALL_Person_Attr THEN
         DO:
            CREATE ALL_Person_Attr.
            ASSIGN
            ALL_Person_Attr.Id  = NEXT-VALUE(Person_Attr_Id, bank)
            ALL_Person_Attr.Person_Id      = iPersonId
            ALL_Person_Attr.FieldName      = iFieldName.
            ALL_Person_Attr.FieldSource    = iFieldSource.
         END.
        IF ALL_Person_Attr.FieldValue <> iFieldValue THEN
         DO:
            ALL_Person_Attr.FieldValue = iFieldValue.
            ALL_Person_Attr.UpdateCount = NEXT-VALUE(Person_UpdateCount, bank).
         END.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS CHAR, p_FieldSource AS CHAR):
        RETURN SetItem(cBPerson:Id, p_FieldName, p_FieldValue, p_FieldSource).
    END.
    
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS INT64, p_FieldSource AS CHAR):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), p_FieldSource).
    END.
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS DATE, p_FieldSource AS CHAR):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), p_FieldSource).
    END.
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS DATETIME, p_FieldSource AS CHAR):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), p_FieldSource).
    END.
 
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS CHAR):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), "").
    END.
    
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS INT64):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), "").
    END.
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS DATE):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), "").
    END.
    METHOD PUBLIC CHAR SetItem(p_FieldName AS CHAR, p_FieldValue AS DATETIME):
        RETURN SetItem(p_FieldName, STRING(p_FieldValue), "").
    END.
 
    METHOD PUBLIC INT64 GetPersonId (p_FieldName AS CHAR, p_FieldValue AS CHAR, p_FieldSource AS CHAR):
        DEF BUFFER ALL_Person_Attr FOR ALL_Person_Attr.
        DEF BUFFER ALL_Person      FOR ALL_Person.
        DEF VAR Val AS INT64 NO-UNDO INIT 0.
        FIND FIRST ALL_Person_Attr NO-LOCK WHERE FieldName   = p_FieldName
                                             AND FieldValue  = p_FieldValue
                                             AND FieldSource = p_FieldSource
                                         NO-ERROR.
        IF AVAILABLE ALL_Person_Attr THEN 
         DO:
            Val = ALL_Person_Attr.Person_Id.
            FIND FIRST ALL_Person WHERE ALL_Person.Id = Val EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE ALL_Person THEN Val = 0.
         END.
        RETURN Val.
    END.
END CLASS.
