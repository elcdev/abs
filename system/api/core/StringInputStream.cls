USING Progress.Lang.*.

CLASS system.api.core.StringInputStream INHERITS Progress.IO.InputStream:
    DEFINE PUBLIC PROPERTY lcVar AS LONGCHAR GET.
    PRIVATE SET.
   
    METHOD OVERRIDE INT64 Read(INPUT pmData AS MEMPTR, INPUT offset AS INT64, INPUT len AS INT64):
            THIS-OBJECT:lcVar = GET-STRING(pmData, 1).
            RETURN GET-SIZE(pmData).
    END METHOD.
    
    METHOD OVERRIDE INT64 Read(INPUT pmData AS MEMPTR):
            THIS-OBJECT:lcVar = GET-STRING(pmData, 1).
            RETURN GET-SIZE(pmData).
    END METHOD.

    METHOD OVERRIDE INT64 Read( INPUT Ddelimiter AS CHARACTER,  OUTPUT target AS CHARACTER ):
        target = STRING(lcVar, "X(10000)").
        RETURN 0.
    END.

    METHOD OVERRIDE INT64 Read( INPUT Idelimiter AS CHARACTER,  OUTPUT target AS LONGCHAR  ):
        target = lcVar.
        RETURN 0.
    END.
    
    METHOD PUBLIC INT64 Write(INPUT lc AS LONGCHAR):
        lcVar = LC.
        RETURN 0.
    END METHOD.
    
END CLASS.

