USING system.api.core.*.
USING system.api.systemSettings.*.
USING system.api.balance.*.
USING Progress.IO.*.

/*
DEF VAR myObj        AS MyClass.
DEF VAR mySerializer AS Progress.IO.JsonSerializer.

DEFINE VARIABLE myStringStream AS StringOutputStream. 
DEFINE VARIABLE myJSON AS LONGCHAR NO-UNDO.

myObj = NEW MyClass().
myStringStream = NEW StringOutputStream().

mySerializer = NEW Progress.IO.JsonSerializer (TRUE).
mySerializer:Serialize(myObj, myStringStream).
myStringStream:Close().

MESSAGE STRING(myStringStream:lcVar)
    VIEW-AS ALERT-BOX.
    
DEFINE VARIABLE tAccount AS accountModel.
tAccount = NEW accountModel().

tAccount:getDb(5).
tAccount:account = "C00000000004".
tAccount:currency = "USD".
MESSAGE STRING(tAccount:toJson()) VIEW-AS ALERT-BOX.

*/


DEFINE VARIABLE myObj           AS accountModel.

/*
DEFINE VARIABLE myFileOutStream AS Progress.IO.FileOutputStream.
DEFINE VARIABLE myFileInStream  AS Progress.IO.FileInputStream.
DEFINE VARIABLE mySerializer    AS Progress.IO.JsonSerializer.
DEFINE VARIABLE json AS LONGCHAR.

COPY-LOB FILE "C:\Projects\abs\sandbox\testDynmicProperties\test.json" TO json.

mySerializer = NEW Progress.IO.JsonSerializer(FALSE).
/* Deserialize object */

myFileInStream = NEW Progress.IO.FileInputStream("C:\Projects\abs\sandbox\testDynmicProperties\test.json").

myObj = DYNAMIC-CAST(mySerializer:Deserialize(myFileInStream), "system.api.balance.accountModel").

myFileInStream:Close().
*/

DEFINE VARIABLE jsonFile AS CHARACTER INITIAL "C:\Projects\abs\sandbox\testDynmicProperties\test.json".

myObj = accountModel:parseJsonFile(jsonFile).

MESSAGE myObj:id SKIP myObj:account SKIP myObj:Currency VIEW-AS ALERT-BOX.
