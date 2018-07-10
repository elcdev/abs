CLASS usersType:
    DEF PUBLIC VAR id        AS INT64 NO-UNDO.
    DEF PUBLIC VAR login     AS CHAR NO-UNDO.
    DEF PUBLIC VAR firstName AS CHAR NO-UNDO.
    DEF PUBLIC VAR lastName  AS CHAR NO-UNDO.

    METHOD PUBLIC CHAR getDb(iId AS INT64):
        DEF BUFFER users FOR users.

        FIND FIRST users WHERE users.id = iId NO-ERROR.
        IF NOT AVAILABLE users THEN RETURN "NOT-FOUND-IN-DB".

        ASSIGN	
        id        = iId
        login     = users.login
        email     = users.email
        firstName = users.first_name
        lastName  = users.last_name
        .

        RETURN "".
    END.

    METHOD PUBLIC CHAR getDb(iLogin AS CHAR):
        RETURN getDb(getIdByLogin(iLogin)).
    END.

    METHOD PUBLIC INT64 getIdByLogin(iLogin AS CHAR):
        DEF BUFFER users FOR users.

        FIND FIRST users WHERE users.login = iLogin NO-ERROR.
        IF NOT AVAILABLE users THEN RETURN -1.

        RETURN users.id.
    END.
END.