USING Progress.Lang.*.


CLASS MyClass SERIALIZABLE:
    DEFINE PUBLIC VARIABLE vMyint AS INT NO-UNDO.
    DEFINE PUBLIC PROPERTY pMychar AS CHAR 
        GET.
        SET.
    DEFINE PROTECTED SERIALIZABLE TEMP-TABLE myTT 
        FIELD myChar AS CHAR
        FIELD myInt  AS INT.
    DEFINE PROTECTED SERIALIZABLE DATASET myDset FOR myTT.
    DEFINE VARIABLE mycls2 AS MyClass2.
    
    CONSTRUCTOR PUBLIC MyClass():
        vMyint = 5.
        pMychar = "pMyCharProperty".
        CREATE myTT.
        myTT.myChar = "hello world".
        myTT.myInt = 255.
        mycls2 = NEW MyClass2().
        mycls2:vMyint2 = 500.
        mycls2:myColors = Colors:Red.
    END CONSTRUCTOR.
END CLASS.

