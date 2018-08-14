USING Progress.Lang.*.

CLASS garbageCollectorType:
    DEFINE TEMP-TABLE tmpObjects NO-UNDO
        FIELD objectReference   AS CLASS Progress.Lang.Object
        .
    
    DESTRUCTOR garbageCollectorType():
        FOR EACH tmpObjects:
            DELETE OBJECT tmpObjects.objectReference NO-ERROR.
            DELETE tmpObjects.
        END.
    END.
    
    METHOD PUBLIC CHARACTER addItem(iObject AS Progress.Lang.Object):
        CREATE tmpObjects.
        tmpObjects.objectReference = iObject.
        RETURN "".
    END.
END.