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
END CLASS.