USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

DEFINE VARIABLE dbSettings AS CLASS databaseConnections.

dbSettings = NEW databaseConnections().

dbSettings:addItem("absdb", "absdb", "absdb", "localhost", "10000", "-db absdb -H localhost -S 10000").
dbSettings:saveSettings().

MESSAGE databaseConnections:getConnectionString("system") VIEW-AS ALERT-BOX.
MESSAGE databaseConnections:getConnectionString("system1") VIEW-AS ALERT-BOX.

DELETE OBJECT dbSettings NO-ERROR.