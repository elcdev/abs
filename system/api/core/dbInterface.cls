USING system.api.core.*.

INTERFACE system.api.core.dbInterface:
	METHOD PUBLIC CHARACTER putDb():
    METHOD PUBLIC CHARACTER getDb(iId AS INT64):
	METHOD PUBLIC CHARACTER getJson():
END INTERFACE.