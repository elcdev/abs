USING system.api.core.*.

CLASS system.api.core.requestBase SERIALIZABLE IMPLEMENTS requestInterface:
    DEFINE PUBLIC VARIABLE action  AS CHARACTER NO-UNDO.
    DEFINE PUBLIC VARIABLE id      AS INTEGER   NO-UNDO.
	DEFINE PUBLIC VARIABLE version AS INTEGER   NO-UNDO.

    METHOD PUBLIC CHARACTER getDb():
        RETURN "NOT-EMPLEMENTED".
    END.
    METHOD PUBLIC CHARACTER putDb():
        RETURN "NOT-EMPLEMENTED".
    END.
    METHOD PUBLIC CHARACTER getJson():
        RETURN "NOT-EMPLEMENTED".
    END.
END CLASS.