CLASS MySql:
    DEF PUBLIC VAR cStr             AS sysstr         NO-UNDO.
    DEF PUBLIC VAR cDbProgressRepl  AS dbProgressRepl NO-UNDO.
    
    DEF PUBLIC VAR ErrShowEnabled   AS LOG      NO-UNDO INIT YES.
    DEF PUBLIC VAR NO-EXECUTE       AS INT      NO-UNDO INIT 0.
    DEF PUBLIC VAR MAKE-OUTPUT-FILE AS INT      NO-UNDO INIT 0.
    DEF PUBLIC VAR MaxRecordCounter AS INT64    NO-UNDO INIT 100.
    DEF PUBLIC VAR Err              AS LOG      NO-UNDO INIT NO.
    DEF PUBLIC VAR Err_Txt          AS CHAR     NO-UNDO.
    DEF PUBLIC VAR OutXml           AS LONGCHAR NO-UNDO.
    DEF PUBLIC VAR DB_NAME          AS CHAR     NO-UNDO INIT "".
    DEF PUBLIC VAR DB               AS CHAR     NO-UNDO INIT "norvikeu_rc".
    DEF PUBLIC VAR DB_HOST          AS CHAR     NO-UNDO INIT "site3.ltk".
    DEF PUBLIC VAR DB_TABLE         AS CHAR     NO-UNDO.
    DEF PUBLIC VAR DB_USER          AS CHAR     NO-UNDO INIT "norvik".
    DEF PUBLIC VAR DB_PASS          AS CHAR     NO-UNDO INIT "devPWD21".
    DEF PUBLIC VAR DEBUG            AS INT64    NO-UNDO INIT 0.
    DEF PUBLIC VAR DRIVER           AS INT64    NO-UNDO INIT 0. /* 0-MySql; 1-TDS MSSQL; */
    DEF PUBLIC VAR TSQL_PATH        AS CHAR     NO-UNDO INIT "tsql".
    DEF PUBLIC VAR Count            AS INT64    NO-UNDO INIT 0.
    DEF PUBLIC VAR SYS_TYPE         AS CHAR     NO-UNDO.
    DEF PUBLIC VAR HOSTNAME         AS CHAR     NO-UNDO.
    DEF PUBLIC VAR EXTENTDELIMITER  AS CHAR     NO-UNDO INIT "_". 
    DEF PUBLIC VAR recordCount      AS INT64    NO-UNDO INIT 0.
    DEF PUBLIC VAR OutputFileNAme   AS CHAR     NO-UNDO.
    
    DEF VAR DATATYPE_NUMERIC   AS CHAR INIT "NUMBER;DEC;DECIMAL;DOUBLE PRECISION;FLOAT;INTEGER;INT;NUMERIC;REAL;SMALLINT;SIGNTYPE;".
    DEF VAR DATATYPE_CHARACTER AS CHAR INIT "CHAR;CHARACTER;LONG;LONG RAW;VARCHAR2;VARCHAR;NCHAR;NVARCHAR;NVARCHAR2;".
    DEF VAR DATATYPE_BOOLEAN   AS CHAR INIT "BOOLEAN;".
    
    DEF PUBLIC VAR DRIVER_MYSQL    AS INT64 NO-UNDO INIT 0.
    DEF PUBLIC VAR DRIVER_MSSQL    AS INT64 NO-UNDO INIT 1.
    DEF PUBLIC VAR DRIVER_ORACLE   AS INT64 NO-UNDO INIT 2.    
    {const_systype.i PUBLIC}
    
    DEFINE TEMP-TABLE tObjHolder NO-UNDO
         FIELD Id   AS INT64
         FIELD Obj  AS CLASS Progress.Lang.Object
         INDEX ID ID.
    DEFINE TEMP-TABLE dbSchema NO-UNDO
        FIELD HOST_NAME      AS CHAR FORMAT "X(10)"
        FIELD schemaName     AS CHAR FORMAT "X(15)"
        FIELD tableName      AS CHAR FORMAT "X(10)"
        FIELD fieldName      AS CHAR FORMAT "X(10)"
        FIELD fieldType      AS CHAR FORMAT "X(10)"
        FIELD fieldLength    AS INT64
        FIELD fieldPrecision AS INT64
        FIELD fieldScale     AS INT64
        FIELD fieldOrd       AS INT
        INDEX PK fieldName tableName schemaName HOST_NAME
        INDEX tableName tableName
        INDEX fieldOrd schemaName tableName fieldOrd
        .
    
    DEF PUBLIC VAR TSQL_OK AS LOG NO-UNDO.
    
    CONSTRUCTOR MySql():
        cstr = NEW sysstr().
        Init(0).
    END.
 
    CONSTRUCTOR MySql(p_Host AS CHAR, p_Db AS CHAR):
        DB_HOST = p_Host.
        DB      = p_Db.
        cstr = NEW sysstr().    
        Init(0).
    END.
     
    DESTRUCTOR MySql():
        DELETE OBJECT cstr            NO-ERROR.
        DELETE OBJECT cDbProgressRepl NO-ERROR.
        Empty().
    END.
    
    METHOD PUBLIC LOG Check_Tsql():
        DEF VAR str AS CHAR NO-UNDO.
        INPUT THROUGH VALUE(TSQL_PATH + " -C|grep co").
        IMPORT str.
        INPUT CLOSE.
        TSQL_OK = No.
        IF str = "Compile-time" THEN TSQL_OK = Yes.
        ELSE
         DO:
            MESSAGE "MSSQL [tsql] client is not installed!" VIEW-AS ALERT-BOX.
         END.
        RETURN TSQL_OK.
    END.
    
    METHOD INT InitByWebSiteDomainName(wwwDomain AS CHAR):
        IF      wwwDomain = "www.norvik.eu"   THEN Init(1).
        ELSE IF wwwDomain = "forex.norvik.eu" THEN Init(1).
        ELSE Init(2).
    END.
    
    METHOD PUBLIC CHAR GetEnvironment ():
        DEF VAR Msg  AS CHAR NO-UNDO.
        DEF VAR tMsg AS CHAR NO-UNDO.
        INPUT THROUGH set.
        REPEAT:
            IMPORT tMsg.
            Msg = Msg + tMsg + CHR(10).
        END.
        INPUT CLOSE.
        RETURN Msg.
    END.
    METHOD INT Init(modeTestProduction AS INT):
        DEF VAR cdb AS syspdb NO-UNDO.
        cdb = NEW syspdb().
        HOSTNAME = cdb:cfso:HostName().
        IF modeTestProduction = 0 THEN 
         DO:
             SYS_TYPE = cdb:GetSysType().
         END.
        ELSE IF modeTestProduction = 1 THEN /* */
         DO:
            SYS_TYPE =  SYSTYPE-PROD.
         END.
        ELSE IF modeTestProduction = 2 THEN /* */
         DO:
            SYS_TYPE =  SYSTYPE-TEST.
         END.
        IF SYS_TYPE =  SYSTYPE-TEST THEN
         DO:
            DB          = "bank".
            DB_HOST     = "site3.ltk".
            DB_TABLE    = "".
            DB_USER     = "norvik".
            DB_PASS     = "devPWD21".
         END.
        ELSE IF SYS_TYPE =  SYSTYPE-PROD THEN
         DO:
            DB          = "bank".
            DB_HOST     = "bukahanew.ltk".
            DB_TABLE    = "".
            DB_USER     = "norvik".
            DB_PASS     = "ZJO5vQKgxTkjczVdDwCQQJvk-Vsb5TTs".
         END.
        IF NOT Check_Tsql() THEN
         DO:
            DEF VAR Msg AS CHAR NO-UNDO.
            Msg = GetEnvironment().
            /******
            cdb:cfso:SendMail("admin@norvik.eu", "Can't find TSQL programm on server [" + cdb:cfso:HostName() + "]", Msg ).
            *******/
            
         END.
        DELETE OBJECT cdb NO-ERROR.
    END.
    /* Список Banks формируется по типам сумм */
    METHOD PUBLIC INT64 AddItem(tObj AS MySql_ROWS):
        Count = Count + 1.
        CREATE tObjHolder.
        tObjHolder.Id  = Count.
        tObjHolder.Obj = tObj.
        RETURN Count.
    END.
    METHOD PUBLIC INT64 Empty():
        Err = False.
        DEF VAR tObj AS MySql_ROWS NO-UNDO.
        FOR EACH tObjHolder:
            IF VALID-OBJECT(tObjHolder.Obj) THEN
             DO:
                tObj = CAST(tObjHolder.Obj, "MySql_ROWS").
                tObj:Empty().
                DELETE OBJECT tObj NO-ERROR.
             END.
            DELETE tObjHolder NO-ERROR.
        END.
        Count = 0.
        RETURN 0.
    END.
    METHOD PUBLIC INT64 ShowError():
        IF Err AND ErrShowEnabled THEN MESSAGE Err_Txt VIEW-AS ALERT-BOX.
        IF Err THEN
         DO:
            log-manager:write-message("MySql.cls: DB_HOST=" + DB_HOST + "; DB_USER=" 
            + DB_USER + "; DB=" + DB + "; DB_PASS=" +  DB_PASS).
            log-manager:write-message(Err_Txt).
        END.
    END.
    
    METHOD PUBLIC CHAR TMPFILE ():
        RETURN TMPFILE("", "").
    END.
    METHOD PUBLIC CHAR TMPFILE (pPref AS CHAR, pExt AS CHAR):
        IF pExt = "" THEN ".tmp".
        IF DEBUG > 0 THEN RETURN "./" + STRING(guid) + pExt.
        RETURN "/tmp/" + STRING(guid) + pExt.
    END.
    METHOD PUBLIC INT64 Execute (Sql AS CHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        DEF VAR pSql AS LONGCHAR NO-UNDO.
        pSql = Sql.
        RETURN Execute (pSql, DB, 0, pRows).
    END.
    METHOD PUBLIC INT64 Execute (Sql AS LONGCHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        RETURN Execute (Sql, DB, 0, pRows).
    END.
    
    METHOD PUBLIC INT64 Execute (Sql AS CHAR, f_Db AS CHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        DEF VAR pSql AS LONGCHAR NO-UNDO.
        pSql = Sql.
        RETURN Execute (pSql, f_Db, 0, pRows).
    END.
    
    METHOD PUBLIC INT64 Execute (Sql AS LONGCHAR, f_Db AS CHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        RETURN Execute (Sql, f_Db, 0, pRows).
    END.
    METHOD PUBLIC MySql_ROWS OpenRecordset(Sql AS CHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        DEF VAR pSql AS LONGCHAR NO-UNDO.
        pSql = Sql.
        pRows = NEW MySql_ROWS().
        AddItem(pRows).
        Execute (pSql, DB, 0, pRows).
        RETURN pRows.
    END.
    
    METHOD PUBLIC MySql_ROWS OpenRecordset(Sql AS LONGCHAR):
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        pRows = NEW MySql_ROWS().
        AddItem(pRows).
        Execute (Sql, DB, 0, pRows).
        RETURN pRows.
    END.
    METHOD PUBLIC MySql_ROWS OpenRecordset(Sql AS CHAR, f_Db AS CHAR):
        DEF VAR pRows AS MySql_ROWS NO-UNDO.
        DEF VAR pSql  AS LONGCHAR NO-UNDO.
        pSql = Sql.
        pRows = NEW MySql_ROWS().
        AddItem(pRows).
        Execute (pSql, f_DB, 0, pRows).
        RETURN pRows.
    END.    
    METHOD PUBLIC MySql_ROWS OpenRecordset(Sql AS LONGCHAR, f_Db AS CHAR):
        DEF VAR pRows   AS MySql_ROWS.
        pRows = NEW MySql_ROWS().
        pRows:cMkField:DEBUG = DEBUG.
        AddItem(pRows).
        Execute(Sql, f_Db, 0, pRows).
        RETURN pRows.
    END.
    METHOD PUBLIC LONGCHAR maskSpecialChars(iStr AS LONGCHAR):
        iStr = REPLACE(iStr, "$", '\\$').
        iStr = REPLACE(iStr, "'", '\\''').
        /*iStr = REPLACE(iStr, CHR(126), '\\' + CHR(126)).*/
        RETURN iStr.
    END.
    
    METHOD PUBLIC CHARACTER maskSpecialChars(iStr AS CHAR):
        DEFINE VARIABLE tStr AS LONGCHAR NO-UNDO.
        tStr = iStr.
        iStr = STRING(maskSpecialChars(tStr)).
        RETURN iStr.
    END.
    
    METHOD PUBLIC INT64 Execute (Sql AS LONGCHAR, f_Db AS CHAR, f_Mode AS INT64, f_Rows AS MySql_ROWS):
        IF NO-EXECUTE = 1 THEN RETURN 0.
        DEF VAR MySqlCmd AS CHAR     NO-UNDO.
        DEF VAR Rez      AS INT64    NO-UNDO INIT 0. /* 0 = No error */
        DEF VAR ErrTxt   AS LONGCHAR NO-UNDO.
        DEF VAR cb       AS INT64    NO-UNDO.
        DEF VAR ce       AS INT64    NO-UNDO.
        DEF VAR fout     AS CHAR     NO-UNDO. /* Output result             */
        DEF VAR fsql     AS CHAR     NO-UNDO. /* Input SQL query in UTF-8  */
        DEF VAR ferr     AS CHAR     NO-UNDO. /* Output Error description  */
        
        IF Sql = ""  THEN RETURN -1. /* No queryies to execute */
        IF f_Db <> "" THEN
         DO:
            IF SetDb(f_Db) = 0 THEN f_Db = "".
         END.
        IF f_Db = "" THEN f_Db = Db.
        fout = TMPFILE ("", ".xml").
        fsql = TMPFILE ("", ".sql"). 
        ferr = TMPFILE ("", ".err").
        OutputFileName = fout.
        
        Err_Txt = "".
        Err = False.
        IF DRIVER = DRIVER_MYSQL THEN
         DO:
            MySqlCmd = "mysql".
            IF SEARCH(MySqlCmd) eq ? THEN MySqlCmd = "/bank/platon/bin/mysql".
            IF SEARCH(MySqlCmd) eq ? THEN MySqlCmd = "/usr/sfw/bin/mysql".
            IF SEARCH(MySqlCmd) eq ? THEN MySqlCmd = "/usr/bin/mysql".
            IF SEARCH(MySqlCmd) eq ? THEN 
             DO:
                /* ERROR */
                Err_Txt = "MYSQL client is not installed! [" + MySqlCmd + "]".
                Err = True.
                Rez = -1.
                ShowError().
                RETURN Rez.
             END.
            
            MySqlCmd = MySqlCmd + " --xml -h " + DB_HOST + " -u " + maskSpecialChars(DB_USER).
            IF DB_PASS <> "" THEN MySqlCmd = MySqlCmd + " -p" + maskSpecialChars(DB_PASS).
            MySqlCmd = MySqlCmd + " -D " + f_DB.
            
            Sql = "SET NAMES 'utf8';" + Sql.
            IF LENGTH(Sql) > 200 THEN
             DO:
                COPY-LOB Sql TO FILE fsql CONVERT TARGET CODEPAGE "UTF-8".
                MySqlCmd = MySqlCmd + "<" + fsql.
             END.
            ELSE
             DO:
               Sql = cstr:sys_convert_str(Sql, "UTF-8", "").   
                MySqlCmd = MySqlCmd + " -e """ + Sql +  """".
             END.
         END.
        ELSE
         DO:
            MySqlCmd = TSQL_PATH.
            IF NOT TSQL_OK THEN
             DO:
                /* ERROR */
                Err_Txt = "MSSQL [tsql] client is not installed! [" + MySqlCmd + "]".
                Err = True.
                Rez = -2.
                ShowError().
                RETURN Rez.
             END.
            MySqlCmd = MySqlCmd + " -S " + DB_HOST + " -U " + maskSpecialChars(DB_USER) + " -P " + maskSpecialChars(DB_PASS) + " -p 1433 -D " + f_DB + " -x -q".
            IF LENGTH(Sql) > 200 THEN
             DO:
                Sql = Sql + chr(10) + "go" +  chr(10).
                COPY-LOB Sql TO FILE fsql CONVERT TARGET CODEPAGE "UTF-8".
                MySqlCmd = MySqlCmd + " <" + fsql.
             END.
            ELSE
             DO:
                Sql = cstr:sys_convert_str(Sql, "UTF-8", "").
                MySqlCmd = MySqlCmd + " -e """ + SQL +  """".
             END.
         END.
        MySqlCmd = MySqlCmd + " 2>" + ferr.
        MySqlCmd = MySqlCmd + "|cv _ " + fout + " utf koi --NO-ZERROS".
        IF DEBUG > 14 THEN
         DO:
            ErrTxt = MySqlCmd.
            COPY-LOB ErrTxt TO FILE "./" + GUID + ".cmd".
         END.
        OS-COMMAND SILENT VALUE(MySqlCmd).
        COPY-LOB FILE ferr TO ErrTxt NO-ERROR.
        COPY-LOB FILE fout TO OutXml NO-ERROR.
        IF ErrTxt BEGINS "ERROR" AND DRIVER = DRIVER_MYSQL OR (NOT (OutXml BEGINS "<?xml") AND ErrTxt <> "") AND DRIVER = DRIVER_MSSQL THEN
         DO:
            Err_Txt = ErrTxt + CHR(10) + "SQL: " + SUBSTRING(Sql, 1, 500). 
            ErrTxt = ErrTxt  + CHR(10) + "cmd: " + MySqlCmd + "]".
            COPY-LOB ErrTxt TO FILE ferr NO-ERROR.
            Err = True.
         END.
        IF DEBUG < 5 THEN
         DO:
            IF MAKE-OUTPUT-FILE = 0 THEN OS-DELETE VALUE(fout) NO-ERROR.
            OS-DELETE VALUE(fsql) NO-ERROR.
            OS-DELETE VALUE(ferr) NO-ERROR.
         END.
        IF VALID-OBJECT (f_Rows) THEN 
         DO:
            f_Rows:Empty().
            f_Rows:Err = Err.
                        Rez = -3.
            IF NOT Err AND LENGTH(OutXml) > 0 AND MAKE-OUTPUT-FILE = 0 THEN 
                f_Rows:FromXml(OutXml).
         END.
        ShowError().
        RETURN Rez.
    END.
    
    METHOD PUBLIC CHAR SQL_DATE (DT AS DATE):
        IF DT = ? THEN RETURN "NULL".
        RETURN "'" + TRIM(STRING(YEAR(DT), "9999")) + "-" + TRIM(STRING(MONTH(DT), "99")) + "-"
                + TRIM(STRING(DAY(DT), "99")) + "'".
    END.
    METHOD PUBLIC CHAR SQL_DATE (DT AS DATETIME):
        IF DT = ? THEN RETURN "NULL".
        RETURN "'" + TRIM(STRING(YEAR(DT), "9999")) + "-" + TRIM(STRING(MONTH(DT), "99")) + "-"
                + TRIM(STRING(DAY(DT), "99")) 
                + " "
                + TRIM(REPLACE(SUBSTRING(STRING(DT, "99/99/9999 hh:mm:ss"), 12, 8), "????????", ""))
                + "'".
    END.
     
    METHOD PUBLIC LONGCHAR Sql (Val AS INT64):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "" + STRING(Val) + "".    
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS DATETIME):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = SQL_DATE(Val).
        RETURN v.
    END.
    
    METHOD PUBLIC LONGCHAR Sql (Val AS DATE):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = SQL_DATE(Val).
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS DEC):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "'" + STRING(Val) + "'".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS CHAR):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "N'" + REPLACE(STRING(Val), "'", "''") + "'".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS LONGCHAR):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "N'" + REPLACE(Val, "'", "''") + "'".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS INT):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "" + STRING(Val) + "".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR Sql (Val AS LOG):
        DEF VAR v AS LONGCHAR NO-UNDO.
        IF Val THEN v = "1".  ELSE v = "0".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR SqlTim (Val AS INT):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "'" + STRING(Val, "hh:mm:ss") + "'".
        RETURN v.
    END.
    METHOD PUBLIC LONGCHAR SqlTim (Val AS INT64):
        DEF VAR v AS LONGCHAR NO-UNDO.
        v = "'" + STRING(Val, "hh:mm:ss") + "'".
        RETURN v.
    END.
    
    /* Типо-зависимые перекрытия методов */
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS DATE):
        RETURN Sql(Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS DATETIME):
        RETURN Sql(Val).
    END.
    
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS DEC):
        RETURN Sql(Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS LOG):
        /* ?? Preobrazovanije = ? */
        RETURN Sql(Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS INT64):
        RETURN Sql(DB_TABLE, p_fieldName, Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS CHAR):
        RETURN Sql(Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS LONGCHAR):
        RETURN Sql(Val).
    END.
    
    METHOD PUBLIC LONGCHAR Sql(p_tableName AS CHAR, p_fieldName AS CHAR, Val AS INT64):
        DEF VAR DataType AS CHAR NO-UNDO.
        DataType = GetMySqlFieldDataType(DB, p_tableName, p_fieldName).
        
        IF DataType = "time" OR DataType = "datetime" OR DataType = "date" THEN
         DO:
            RETURN SqlTim (Val).
         END.
         
        RETURN Sql(Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_fieldName AS CHAR, Val AS INT):
        RETURN Sql(DB_TABLE, p_fieldName, Val).
    END.
    METHOD PUBLIC LONGCHAR Sql(p_tableName AS CHAR, p_fieldName AS CHAR, Val AS INT):
        DEF VAR v AS INT64 NO-UNDO.
        v = Val.
        RETURN Sql(v).
    END.
    
    METHOD PUBLIC INT fillDbSchema(iSchemaName AS CHAR, iTableName AS CHAR):
        IF DRIVER = 0 THEN RETURN FillHostDatabaseSchemaMY (iSchemaName, iTableName).
        RETURN FillHostDatabaseSchemaMS (iSchemaName, iTableName).
    END.
    
    METHOD INT FillSchemaByRows(pRows   AS MySql_ROWS, p_schemaName AS CHAR, p_tableName AS CHAR):
        /* Podgruzhajem dannyje s web stranicy [bank] */
        DEF VAR idx AS INT64 NO-UNDO.
        DO idx = 1 TO pRows:Count:
            CREATE dbSchema.
            dbSchema.HOST_NAME      = DB_HOST.
            dbSchema.schemaName     = pRows:Item(idx):Item("TABLE_SCHEMA").
            dbSchema.tableName      = pRows:Item(idx):Item("TABLE_NAME").
            dbSchema.fieldName      = pRows:Item(idx):Item("COLUMN_NAME").
            dbSchema.fieldType      = pRows:Item(idx):Item("DATA_TYPE").
            dbSchema.fieldLength    = pRows:Item(idx):Item_I64("CHARACTER_MAXIMUM_LENGTH").
            dbSchema.fieldPrecision = pRows:Item(idx):Item_I64("PRECISION").
            dbSchema.fieldScale     = pRows:Item(idx):Item_I64("SCALE").
            dbSchema.fieldOrd       = pRows:Item(idx):Item_I64("ORDINAL_POSITION").
        END.
        IF  pRows:Count <= 0 THEN
         DO:
            CREATE dbSchema.
            dbSchema.HOST_NAME   = DB_HOST.
            dbSchema.schemaName  = p_schemaName.
            dbSchema.tableName   = p_tableName.
            IF DEBUG > 5 THEN 
             DO:
                MESSAGE "(MySql.cls:FillSchemaByRows) Table [" p_tableName "] or query fields are not parsed!". 
                PAUSE 2.
             END.
         END.
        RETURN 0.
    END.
    METHOD INT FillHostDatabaseSchemaMY (p_schemaName AS CHAR, p_tableName AS CHAR):
        DEF VAR sql AS CHAR  NO-UNDO.
        FIND FIRST dbSchema WHERE schemaName = p_schemaName NO-ERROR.
        IF AVAILABLE dbSchema THEN RETURN 0.
        
        sql = "SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, `NUMERIC_PRECISION` 'PRECISION', `NUMERIC_SCALE` 'SCALE', ORDINAL_POSITION 
                 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '" + p_schemaName + "'".
        IF p_tableName <> "" THEN sql = sql + " AND TABLE_NAME = '" + p_tableName + "'". 
        
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        pRows = OpenRecordset(sql, DB).
        FillSchemaByRows(pRows, p_schemaName, p_tableName).
        DELETE OBJECT pRows NO-ERROR.
        RETURN 0.
    END.
    METHOD INT FillHostDatabaseSchemaMS (p_schemaName AS CHAR, p_tableName AS CHAR):
        DEF VAR sql AS LONGCHAR  NO-UNDO.
        FIND FIRST dbSchema WHERE schemaName = p_schemaName NO-ERROR.
        IF AVAILABLE dbSchema THEN RETURN 0.
        sql = "select DB_NAME() [TABLE_SCHEMA], obj.name [TABLE_NAME], cols.name [COLUMN_NAME], types.name [DATA_TYPE], 
                      cols.max_length [CHARACTER_MAXIMUM_LENGTH], cols.precision [PRECISION], cols.scale [SCALE], colls.column_id [ORDINAL_POSITION]
               from sys.all_objects obj
               inner join sys.all_columns cols
               on obj.object_id = cols.object_id 
               inner join sys.types types
               on types.system_type_id = cols.system_type_id 
               where (obj.type = 'P' or obj.type = 'V' or obj.type = 'U')".
        IF p_tableName <> "" THEN sql = sql + " AND obj.NAME = '" + p_tableName + "'". 
        
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        pRows = OpenRecordset(sql, DB).
        
        FillSchemaByRows(pRows, p_schemaName, p_tableName).
        DELETE OBJECT pRows NO-ERROR.
       RETURN 0.
    END.
 
    METHOD PUBLIC CHAR GetMySqlTableFieldsList(p_tableName AS CHAR):
        RETURN GetMySqlTableFieldsList("", p_tableName).
    END.
    METHOD PUBLIC CHAR GetMySqlTableFieldsList(p_schemaName AS CHAR, p_tableName AS CHAR):
        IF p_schemaName <> "" THEN DB = p_schemaName. ELSE p_schemaName = DB.
        fillDbSchema (p_schemaName, p_tableName).
        DEF VAR sql        AS LONGCHAR  NO-UNDO.
        DEF VAR fieldsList AS CHAR NO-UNDO INIT "".
        sql = "INSERT INTO " + p_tableName + " (". 
        FOR EACH dbSchema WHERE dbSchema.HOST_NAME    = DB_HOST
                                  AND dbSchema.schemaName = p_schemaName
                                  AND dbSchema.tableName   = p_tableName:
            IF fieldsList <> "" THEN fieldsList = fieldsList + ", ".
            fieldsList = fieldsList + dbSchema.fieldName.
        END.
        sql = sql + fieldsList + ") values (".
        RETURN fieldsList.
    END.
    
    METHOD PUBLIC CHAR GetMySqlFieldDataType(p_schemaName AS CHAR, p_tableName AS CHAR, p_fieldName AS CHAR):
        RETURN  GetMySqlFieldDataType(p_schemaName, p_tableName, p_fieldName, 0).
    END.
    
    METHOD PUBLIC CHAR GetMySqlFieldDataType(p_schemaName AS CHAR, p_tableName AS CHAR, p_fieldName AS CHAR, 
                                             p_DoNotLoadSchema AS INT):
        FIND FIRST dbSchema WHERE dbSchema.HOST_NAME    = DB_HOST
                                    AND dbSchema.schemaName = p_schemaName
                                    AND dbSchema.tableName   = p_tableName
                                    AND dbSchema.fieldName  = p_fieldName
                                    NO-ERROR.
        IF NOT AVAILABLE dbSchema THEN 
         DO:
            IF p_DoNotLoadSchema = 0 THEN 
             DO:
                fillDbSchema(p_schemaName, p_tableName).
                
                RETURN GetMySqlFieldDataType(p_schemaName, p_tableName, p_fieldName, 1).
             END.
            RETURN "".
         END.
         RETURN dbSchema.fieldType.
    END.
    
    
    
    METHOD PUBLIC INT64 Update_MySql_Table_Record(pSourceTable AS CHAR, pRecordId AS INT64, pAction AS CHAR):
        DEF VAR uc AS INT64 NO-UNDO.
        RETURN Update_MySql_Table_Record("bank", pSourceTable, DB_HOST, DB, pSourceTable, pRecordId, pAction, INPUT-OUTPUT uc, ?).
    END.
    METHOD PUBLIC INT64 Update_MySql_Table_Record( pSourceDatabase AS CHAR, pSourceTable AS CHAR, 
                                                   pDestinationHost AS CHAR, pDestinationDatabase AS CHAR,
                                                   pRecordId AS INT64, pAction AS CHAR
                                                  ):
        DEF VAR uc AS INT64 NO-UNDO.
        RETURN Update_MySql_Table_Record(pSourceDatabase, pSourceTable, DB_HOST, DB, pSourceTable, 
                                         pRecordId, pAction, INPUT-OUTPUT uc, ?).
    END.
    METHOD PUBLIC INT64 Update_MySql_Table_Record( pSourceDatabase AS CHAR, pSourceTable AS CHAR, 
                                                   pDestinationHost AS CHAR, pDestinationDatabase AS CHAR,
                                                   pRecordId AS INT64, pAction AS CHAR,
                                                   INPUT-OUTPUT pUpdateCount AS INT64
                                                  ):
        RETURN Update_MySql_Table_Record(pSourceDatabase, pSourceTable, 
                                         pDestinationHost, pDestinationDatabase, pSourceTable,
                                         pRecordId, pAction, INPUT-OUTPUT pUpdateCount, ?).
    END.
    /* Returns: <0 if error ; 0>= Number of replicated records */
    
    METHOD PUBLIC INT64 Update_MySql_Table_Record( pSourceDatabase           AS CHAR, 
                                                   pSourceTable              AS CHAR, 
                                                   pDestinationHost          AS CHAR, 
                                                   pDestinationDatabase      AS CHAR,  
                                                   pDestinationTable         AS CHAR,
                                                   pRecordId                 AS INT64, 
                                                   pAction                   AS CHAR,
                                                   INPUT-OUTPUT pUpdateCount AS INT64
                                                  ):
        RETURN Update_MySql_Table_Record(pSourceDatabase, pSourceTable, 
                                         pDestinationHost, pDestinationDatabase, pDestinationTable,
                                         pRecordId, pAction, INPUT-OUTPUT pUpdateCount, ?).
    END.
    
    METHOD PUBLIC CHAR transformFieldName(iFieldName AS CHAR, iExtentCounter AS INT, iTableState AS replTableStateType):
        IF iExtentCounter > 0 THEN iFieldName = iFieldName + EXTENTDELIMITER + STRING(iExtentCounter).
        IF VALID-OBJECT(iTableState) AND VALID-OBJECT(iTableState:filter) THEN
           iFieldName = iTableState:filter:getAssociatedDestinationField(iFieldName).
        RETURN iFieldName.
    END.
    
    METHOD PUBLIC CHAR validRecord(iSourceBuffer AS HANDLE, iTableState AS replTableStateType):
        IF NOT VALID-OBJECT(iTableState) THEN RETURN "".
        
        IF NOT VALID-OBJECT(iTableState:filter) THEN 
         DO:
            IF iTableState:filterObjectName = "" THEN RETURN "".
            RETURN "INVALID-FILTER-OBJECT".
         END.
        RETURN iTableState:filter:validRecord(iSourceBuffer).
    END.
    
    METHOD PUBLIC INT64 Update_MySql_Table_Record( iSourceDatabase            AS CHAR, 
                                                   iSourceTable               AS CHAR, 
                                                   iDestinationHost           AS CHAR, 
                                                   iDestinationDatabase       AS CHAR,  
                                                   iDestinationTable          AS CHAR,
                                                   iRecordId                  AS INT64, 
                                                   iAction                    AS CHAR,
                                                   INPUT-OUTPUT ioUpdateCount AS INT64,
                                                   iTableState                AS replTableStateType
                                                  ):
        DEF VAR tSql           AS LONGCHAR NO-UNDO.
        DEF VAR pError         AS INT64    NO-UNDO INIT 0.
        DEF VAR MaxUpdateCount AS INT64    NO-UNDO.
        DEFINE VARIABLE fTable              AS CHAR     NO-UNDO.
        DEFINE VARIABLE fForEach            AS CHAR     NO-UNDO.
        DEFINE VARIABLE iFieldCounter       AS INT      NO-UNDO.
        DEFINE VARIABLE iRecordCounter      AS INT      NO-UNDO.
        DEFINE VARIABLE iSql                AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iFieldNames         AS  CHAR            NO-UNDO.
        DEFINE VARIABLE iFieldValues        AS  CHAR            NO-UNDO.
        DEFINE VARIABLE iExtentCounter      AS  INTEGER         NO-UNDO.
        DEFINE VARIABLE tmpQuery            AS  WIDGET-HANDLE   NO-UNDO.
        DEFINE VARIABLE tmpBuffer           AS  HANDLE          NO-UNDO.
        DEFINE VARIABLE tmpField            AS  HANDLE          NO-UNDO.
        DEFINE VARIABLE hFieldBufferHandle  AS  HANDLE          NO-UNDO.
        DEFINE VARIABLE tmpFieldName        AS  CHARACTER       NO-UNDO.
        DEFINE VARIABLE isValidRecord       AS  CHAR            NO-UNDO.
        
        DB      = iDestinationDatabase.
        DB_HOST = iDestinationHost.
        tSql = "".
        IF DRIVER = DRIVER_MYSQL THEN tSql = "START TRANSACTION;" + CHR(10).
        IF DRIVER = DRIVER_MSSQL THEN tSql = "SET ANSI_WARNINGS  OFF;" + CHR(10).
        
        IF NOT (iAction = "INSERT" OR  iAction = "UPDATE") THEN
         DO:
            tSql = tSql + "DELETE FROM " + iDestinationTable 
                + " WHERE " + iDestinationTable + ".id = " + STRING(iRecordId) + ";" + CHR(10).
                iRecordCounter = 1. /* TODO! Analize result! */
         END.
        IF iAction = "INSERT" OR  iAction = "UPDATE" THEN
         DO:
            fTable = iSourceTable.
            DB_TABLE =  iDestinationTable.
            IF iSourceDatabase <> "" THEN fTable = iSourceDatabase + "." + iSourceTable.
            IF iRecordId > 0 THEN 
                fForEach = "for each " + fTable + " no-lock where " + fTable + ".Id = " + STRING(iRecordId).
            ELSE 
                fForEach = "for each " + fTable + " no-lock where " + fTable + ".UpdateCount > " + STRING(ioUpdateCount)
                + " BREAK BY UpdateCount".
                
            CREATE BUFFER   tmpBuffer           FOR TABLE fTable.
            
            CREATE QUERY tmpQuery.
            tmpQuery:SET-BUFFERS(tmpBuffer).
            tmpQuery:QUERY-PREPARE(fForEach).
            tmpQuery:QUERY-OPEN.
            tmpQuery:GET-FIRST.
            iFieldNames = "".
            iFieldValues = "".
            iRecordCounter = 0.
            recordCount = 0.
            IF DEBUG > 3 THEN MESSAGE now iSourceTable "Prepare SQL statement".
            DO WHILE NOT tmpQuery:QUERY-OFF-END:
                iRecordCounter = iRecordCounter + 1.
                IF iRecordCounter > MaxRecordCounter THEN LEAVE.
                iFieldValues = "".
                
                isValidRecord = validRecord(tmpBuffer, iTableState).
                
                DO iFieldCounter = 1 TO tmpBuffer:NUM-FIELDS:
                    
                    tmpField = tmpBuffer:BUFFER-FIELD(iFieldCounter).
                    tmpFieldName = transformFieldName(tmpField:Name, 0, iTableState).
                    MESSAGE tmpField:Name " <=> " tmpFieldName.
                    IF tmpFieldName = "" AND tmpField:EXTENT < 1 THEN NEXT. /* SKIPING FIELD */
                    MESSAGE tmpField:Name " = " tmpFieldName.
                    
                    /* Spisok polej */
                    IF iAction = "INSERT" OR iAction = "UPDATE" THEN
                     DO:
                        IF iRecordCounter = 1 THEN
                         DO:
                            IF tmpField:EXTENT < 1 THEN
                             DO:
                                IF iFieldNames <> "" THEN iFieldNames  = iFieldNames  + ", ".
                                iFieldNames = iFieldNames + tmpFieldName.
                             END.
                            ELSE
                             DO iExtentCounter = 1 TO tmpField:EXTENT:
                                tmpFieldName = transformFieldName(tmpField:Name, iExtentCounter, iTableState).
                                IF tmpFieldName = "" THEN NEXT.
                                IF iFieldNames <> "" THEN iFieldNames  = iFieldNames  + ", ".
                                iFieldNames = iFieldNames + tmpFieldName.
                             END.
                            
                         END.
                        IF tmpField:EXTENT < 1 THEN
                         DO:
                            IF iFieldValues <> "" THEN iFieldValues = iFieldValues + ", ".
                            iFieldValues = iFieldValues + Sql(tmpFieldName, tmpField:BUFFER-VALUE).
                         END.
                        ELSE
                         DO iExtentCounter = 1 TO tmpField:EXTENT:
                            IF iFieldValues <> "" THEN iFieldValues = iFieldValues  + ", ".
                            tmpFieldName = transformFieldName(tmpField:Name, iExtentCounter, iTableState).
                            iFieldValues = iFieldValues + Sql(tmpFieldName, tmpField:BUFFER-VALUE[iExtentCounter]).
                         END.
                        
                     END.
                    ELSE IF iAction = "UPDATE" THEN
                     DO:
                        IF tmpField:EXTENT < 1 THEN
                         DO:
                            IF iFieldValues <> "" THEN iFieldValues = iFieldValues + ", ".
                            iFieldValues = iFieldValues + tmpFieldName + "=" + Sql(tmpFieldName, tmpField:BUFFER-VALUE).
                         END.
                        ELSE
                         DO iExtentCounter = 1 TO tmpField:EXTENT:
                            IF iFieldValues <> "" THEN iFieldValues = iFieldValues  + ", ".
                            tmpFieldName = transformFieldName(tmpField:Name, iExtentCounter, iTableState).
                            iFieldValues = iFieldValues + tmpFieldName + "=" + Sql(tmpFieldName, tmpField:BUFFER-VALUE[iExtentCounter]).
                         END.
                     END.
                    IF  tmpField:Name = "UpdateCount" AND tmpField:BUFFER-VALUE > MaxUpdateCount THEN
                        MaxUpdateCount = tmpField:BUFFER-VALUE.
                    ELSE IF tmpField:Name = "id" AND isValidRecord = "" THEN
                        iSql = iSql + "DELETE FROM " + iDestinationTable
                             + " WHERE " + iDestinationTable + ".id = " 
                             + STRING(tmpField:BUFFER-VALUE) + ";" + CHR(10).
                END.
                
                IF isValidRecord = "" AND (iAction = "INSERT" OR iAction = "UPDATE") THEN
                 DO:
                    iSql = iSql + "INSERT INTO " + iDestinationTable
                         + " (" + iFieldNames + ") VALUES(" + iFieldValues + ");" + CHR(10).
                 END.
                tmpQuery:GET-NEXT().
            END.
            tmpBuffer:BUFFER-RELEASE().
            tmpQuery:QUERY-CLOSE().
            DELETE WIDGET tmpQuery.
         END.
         tSql = tSql + iSql.
         IF DRIVER = 0 AND iSql <> "" THEN tSql = tSql + "COMMIT;" + CHR(10).
         IF DEBUG > 3 THEN MESSAGE now iSourceTable "SQL statement completed".
         IF DEBUG > 3 THEN COPY-LOB tSql TO FILE "CurrentSql.sql".
         IF iRecordCounter > 0 OR iRecordId > 0 THEN
          DO:
            IF Execute(tSql, iDestinationDatabase) < 0 THEN RETURN -1.
          END.
         IF DEBUG > 3 THEN MESSAGE now iSourceTable "SQL statement Executed Ok".
         IF MaxUpdateCount > ioUpdateCount THEN ioUpdateCount = MaxUpdateCount.
         recordCount = iRecordCounter.
         
         RETURN iRecordCounter.
    END.
    
    METHOD PUBLIC CHAR DataType_4GtoTSQL(p_DataType AS CHAR, p_Size AS INT, p_Precision AS INT, p_Scale AS INT):
        IF p_DataType BEGINS "char" THEN
         DO:
            IF p_Size = 0 THEN p_Size = 256.
            IF DRIVER = 1 THEN
                RETURN "NVARCHAR(" + STRING(p_Size) + ")".
            ELSE IF DRIVER = DRIVER_ORACLE THEN
                RETURN "VARCHAR2(" + STRING(p_Size) + ")".
            ELSE
                RETURN "VARCHAR(" + STRING(p_Size) + ")".
            
         END.
        ELSE IF p_DataType BEGINS "longchar" THEN
         DO:
            IF DRIVER = 1 THEN
                RETURN "NVARCHAR(MAX)".
            ELSE IF DRIVER = DRIVER_ORACLE THEN
                RETURN "VARCHAR2(4000)".
            ELSE
                RETURN "VARCHAR(4000)".
         END.
        
        IF DRIVER = DRIVER_ORACLE 
          AND (p_DataType = "int" OR p_DataType = "int64" OR p_DataType  BEGINS "LOG" OR p_DataType BEGINS "DEC") THEN
         DO:
            RETURN "NUMBER".
         END.
        
        IF p_DataType = "int" THEN
         DO:
            
            RETURN "INT".
         END.
        ELSE IF p_DataType = "int64" THEN
            RETURN "BIGINT".
        ELSE IF p_DataType BEGINS "DATE" THEN
         DO:
            IF DRIVER = DRIVER_ORACLE THEN RETURN "DATE".
            RETURN "DATETIME".
         END.
        ELSE IF p_DataType  BEGINS "LOG" THEN
            RETURN "BIT".
        IF p_DataType BEGINS "DEC" THEN
         DO:
            IF p_Precision = 0 THEN p_Precision = 21.
            IF p_Scale = 0  THEN p_Scale = 3. 
            RETURN "DECIMAL(" + STRING(p_Precision) + "," + STRING(p_Scale) + ")".
         END.
    
        RETURN "TEXT".
    END.
    METHOD PUBLIC LONGCHAR Script_Create_Table (tableName AS CHAR):
        DEF VAR Sql              AS LONGCHAR NO-UNDO.
        DEF VAR SqlDesc          AS LONGCHAR NO-UNDO.
        DEF VAR fieldNumber      AS INT      NO-UNDO.
        DEF VAR fieldName        AS CHAR     NO-UNDO.
        DEF VAR fieldExtent      AS INT      NO-UNDO.
        DEF VAR fieldExtentCount AS INT      NO-UNDO.
        DEF VAR openChar  AS CHAR INIT "[".
        DEF VAR closeChar AS CHAR INIT "]".
        
        IF DRIVER = 0 THEN DO: openChar = "`". closeChar = "`". END.
        IF DRIVER = DRIVER_ORACLE THEN DO: openChar = "". closeChar = "". EXTENTDELIMITER = "##". END.
        
        SqlDesc = "".
        FOR EACH _file NO-LOCK WHERE _File._File-Name = tableName:
            Sql = "CREATE TABLE " + openChar + _File._File-Name + closeChar + " (" + chr(10).
            fieldNumber = 0.
            FOR EACH _field OF _File NO-LOCK BREAK BY _Order:
                IF _Field._Extent < 1 THEN fieldExtentCount = 1. ELSE fieldExtentCount = _Field._Extent.
                DO fieldExtent = 1 TO fieldExtentCount:
                    fieldNumber = fieldNumber + 1.
                    fieldName   = _Field._Field-Name.
                    IF fieldExtentCount > 1 THEN fieldName = fieldName + EXTENTDELIMITER + STRING(fieldExtent).
                    IF fieldNumber > 1 THEN Sql = Sql + "," + chr(10).
                    Sql = Sql + "       " + openChar + fieldName + closeChar + " " 
                    + DataType_4GtoTSQL(_Field._Data-Type, 0, 0, _Field._Decimals) .
                    
                    IF _Field._Desc <> "" AND DRIVER = 1 THEN
                        SqlDesc = SqlDesc + "exec sp_addextendedproperty 'MS_Description', N'" + _Field._Desc 
                            + "', 'schema', 'dbo', 'table', '"
                            + _File._File-Name + "', 'column', '" + fieldName + "'; " + CHR(10) + CHR(10).
                END.
            END.
            Sql = Sql + CHR(10) + "   );" + CHR(10) + CHR(10) + SqlDesc.
        END.
        IF Sql = "" THEN MESSAGE "No script generated! Check if table exists in current database". 
        RETURN Sql.
    END.
    /* Create table [tableName] in MySql/MsSql database like table in 4GL PROGRESS */
    METHOD PUBLIC LONGCHAR Create_Table (tableName AS CHAR):
        Execute(Script_Create_Table(tableName)).
    END.
    /*TODO! Delete this method */
    METHOD PUBLIC INT64 LoadMySqlTableIntoProgress(pSqlOrTableName AS CHAR, TABLE-HANDLE pTab BIND):
        RETURN LoadMySqlTableIntoProgress(pSqlOrTableName, Db, TABLE-HANDLE pTab BIND).
    END.
    /*TODO! Delete this method */
    METHOD PUBLIC INT64 LoadMySqlTableIntoProgress(pSqlOrTableName AS CHAR, pDb AS CHAR, TABLE-HANDLE pProgressTab BIND):
        DEF VAR i       AS INT64      NO-UNDO INIT 0.
        DEF VAR c       AS INT64      NO-UNDO INIT 0.
        DEF VAR pRows   AS MySql_ROWS NO-UNDO.
        DEF VAR tbh     AS HANDLE     NO-UNDO.
        DEF VAR Sql     AS CHAR       NO-UNDO.
        /*IF pDb <> "" THEN SetDb(pDb).*/
        IF pSqlOrTableName BEGINS "select" THEN 
            Sql = pSqlOrTableName.
        ELSE
            Sql = "select * from " + pSqlOrTableName.
        
        pRows = OpenRecordset(Sql, pDb).
       
        tbh = pProgressTab:DEFAULT-BUFFER-HANDLE.
        /* Podgruzhajem dannyje s web stranicy [bank_copy] */
        DO I = 1 TO pRows:Count WITH 20 DOWN:
            DO TRANSACTION:
                tbh:BUFFER-CREATE.
                DO c = 1 TO pRows:Item(I):Count:
                    /* ALEZHU TODO! No array support!!! */
                    tbh:BUFFER-FIELD(c):BUFFER-VALUE = pRows:Item(I):Item( tbh:BUFFER-FIELD(c):NAME ) NO-ERROR.
                END.
            END.
        END.
        RETURN i.
    END.
 
    METHOD PUBLIC CHAR InsertIntoTempTable (iSourceSchema AS CHAR, iSql AS CHAR, TABLE-HANDLE hTable BIND):
        DEF VAR pRows              AS MySql_ROWS NO-UNDO.
        DEF VAR pRow               AS MySql_ROW  NO-UNDO.
        DEF VAR tBuffer            AS HANDLE     NO-UNDO.
        DEF VAR tDestinationField  AS HANDLE     NO-UNDO.
        DEF VAR tRecord            AS INT64      NO-UNDO.
        DEF VAR tColumn            AS INT64      NO-UNDO.
        DEF VAR tColName           AS CHAR       NO-UNDO.
        DEF VAR tInvalidColumns    AS CHAR       NO-UNDO.
        
        IF NOT VALID-HANDLE(hTable) THEN RETURN "INVALID-TABLE-HANDLE".
        tBuffer = hTable:DEFAULT-BUFFER-HANDLE.
        
        /* Podgruzhajem dannyje */        
        pRows = OpenRecordset(iSql).
        IF NOT VALID-OBJECT(pRows) THEN RETURN "FAILED-OPEN-RECORDSET".
        recordCount = 0.
        
        DO tRecord = 1 TO pRows:Count WITH 20 DOWN:
            pRow = pRows:Item(tRecord).
            IF NOT VALID-OBJECT(pRow) THEN NEXT.
            
            DO TRANSACTION:
                tBuffer:BUFFER-CREATE.
                DO tColumn = 1 TO pRow:Count:
                    tColName = pRow:ItemName(tColumn).
                    tDestinationField = tBuffer:BUFFER-FIELD(tColName).
                    IF VALID-HANDLE(tDestinationField) THEN
                     DO:
                        /* TODO! Datatypes ASSIGMENT */
                        CASE tDestinationField:DATA-TYPE:
                            WHEN "CHARACTER" THEN tDestinationField:BUFFER-VALUE = pRow:ITEM(tColName).
                            WHEN "LONGCHAR"  THEN tDestinationField:BUFFER-VALUE = pRow:ITEM(tColName).
                            WHEN "INTEGER"   THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_I64(tColName).
                            WHEN "INT64"     THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_I64(tColName).
                            WHEN "DECIMAL"   THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_Dec(tColName).
                            WHEN "DATE"      THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_Dat(tColName).
                            WHEN "DATETIME"  THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_Dtm(tColName).
                            WHEN "LOGICAL"   THEN tDestinationField:BUFFER-VALUE = pRow:ITEM_Log(tColName).
                        END.
                     END.
                    ELSE IF tRecord = 1 THEN
                     DO:
                        tInvalidColumns = tInvalidColumns + "[" + tColName + "], ".
                     END.
                END.
            END.
        END.
        DELETE OBJECT pRows NO-ERROR.
        IF tInvalidColumns <> "" THEN
         DO:
            /* TODO! Send notification warning! Columns not found in destination table */
         END.
        recordCount = tRecord.
        RETURN "".
    END.
 
    DEF TEMP-TABLE MySqlConnections NO-UNDO
        FIELD DB_NAME   AS CHAR FORMAT "X(30)"
        FIELD DB_HOST   AS CHAR
        FIELD DB        AS CHAR
        FIELD DB_USER   AS CHAR
        FIELD DB_PASS   AS CHAR
        FIELD DB_TEST   AS CHAR
        FIELD DB_DRIVER AS INT
        .
    METHOD PUBLIC CHAR AddDb(pDB_NAME AS CHAR, pDB_HOST AS CHAR, 
                             pDB      AS CHAR, pDB_USER AS CHAR, 
                             pDB_PASS AS CHAR, pDB_TEST AS CHAR, 
                             pDRIVER AS INT64):
                             
        IF pDB_PASS = "" AND (pDB_HOST = "bukaha.ltk" OR pDB_HOST = "bukahanew.ltk") AND pDB_USER = "norvik" THEN
         DO:
            pDB_PASS = "ZJO5vQKgxTkjczVdDwCQQJvk-Vsb5TTs".
         END.
        FIND FIRST MySqlConnections WHERE DB_NAME = pDB_NAME NO-ERROR.
        IF NOT AVAILABLE MySqlConnections THEN CREATE MySqlConnections.
        ASSIGN
            MySqlConnections.DB_NAME   = pDB_NAME
            MySqlConnections.DB_HOST   = pDB_HOST
            MySqlConnections.DB        = pDB
            MySqlConnections.DB_USER   = pDB_USER
            MySqlConnections.DB_PASS   = pDB_PASS
            MySqlConnections.DB_TEST   = pDB_TEST
            MySqlConnections.DB_DRIVER = pDRIVER
            .
         
    END.
    
    METHOD PUBLIC INT InitMySqlConnections():
        FIND FIRST MySqlConnections NO-ERROR.
        IF AVAILABLE MySqlConnections THEN RETURN 1.
        AddDb("tigerdev/eventum", "tigerdev", "eventum", "eventum", "evt", "", DRIVER_MYSQL).
        AddDb("bukaha/fondi", "bukaha.ltk", "fondi", "norvik", "", "", DRIVER_MYSQL).
        AddDb("bukaha/norvikeu", "bukaha.ltk", "norvikeu", "norvik", "", "", DRIVER_MYSQL).
        AddDb("bukaha/norvikeu_client_data", "bukaha.ltk", "norvikeu_client_data", "norvik", "", "", DRIVER_MYSQL).
        AddDb("bukaha/bank", "bukaha.ltk", "bank", "norvik", "", "", DRIVER_MYSQL).
        AddDb("bukaha/norvikforex", "bukaha.ltk", "norvikforex", "norvik", "", "", DRIVER_MYSQL).
        AddDb("bukaha/norvikforex_client_data", "bukaha.ltk", "norvikforex_client_data", "norvik", "", "", DRIVER_MYSQL).
        
        AddDb("mt4-repsrv/mt4_repsrv", "mt4-repsrv", "mt4_repsrv", "mt4plat", "mt4plat123", "", DRIVER_MYSQL).
        
        AddDb("site3/norvikeu_rc", "site3.ltk", "norvikeu_rc", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/norvikeu_client_data", "site3.ltk", "norvikeu_client_data", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/fondi", "site3.ltk", "fondi", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/nips", "site3.ltk", "nips", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/bank", "site3.ltk", "bank", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/forex_rc", "site3.ltk", "forex_rc", "norvik", "devPWD21", "", DRIVER_MYSQL).
        AddDb("site3/forex_rc_client_data", "site3.ltk", "forex_rc_client_data", "norvik", "devPWD21", "", DRIVER_MYSQL).
        
        AddDb("pltimp-db/pltimp", "pltimp-db.ltk", "pltimp", "pltimp", "iMpOrT173", "pltimp-db/pltimp_test", DRIVER_MSSQL).
        AddDb("pltimp-db/pltimp_test", "pltimp-db.ltk", "pltimp_test", "pltimp", "iMpOrT173", "", DRIVER_MSSQL).
        
        AddDb("alga-db/algalb", "alga-db.ltk", "algalb", "alga_auto", "auto_alga", "alga-db/alga_lb_test", DRIVER_MSSQL).
        AddDb("alga-db/alga_lb_test", "alga-db.ltk", "alga_lb_test", "alga_auto", "auto_alga", "", DRIVER_MSSQL).
        AddDb("horizon-db/hor-proc", "HORIZON-DB", "hor-proc", "hor-proc", "P@$$word", "horizon-db/hor-proc-test", DRIVER_MSSQL).
        AddDb("horizon-db/hor-proc-test", "HORIZON-DB", "hor-proc-test", "hor-proc", "P@$$word", "", DRIVER_MSSQL).
        
        AddDb("ats-db/crm_test", "ats-db", "crm_test", "testuser", "usertest", "", DRIVER_MSSQL).
        AddDb("ats-db/scan", "ats-db", "scan", "PLTIMP", "iMpOrT173", "", DRIVER_MSSQL). /* depricated !!*/
        AddDb("scan-db/scan", "scan-db.ltk", "scan", "PLTIMP", "iMpOrT173", "", DRIVER_MSSQL).
        
        AddDb("dynamics-db-dev.bank/CRM_Norvik_BIS", "dynamics-db-dev.bank", "CRM_Norvik_BIS", "CRM_Norvik_BIS", 
                "efbe5ce2", "", DRIVER_MSSQL).
        AddDb("dynamics-db-prd.bank/CRM_Norvik_BIS", "dynamics-db-prd.bank", "CRM_Norvik_BIS", "CRM_Norvik_BIS", 
                "efbe5ce2", "dynamics-db-dev.bank/CRM_Norvik_BIS", DRIVER_MSSQL).
        
        AddDb("aml-db/amldbprod", "aml-db", "amldbprod", "platon", "wMFzhMW\~S'8n", "aml-db/amldbdev", DRIVER_MSSQL).
        AddDb("aml-db/amldbdev", "aml-db", "amldbdev", "platon", "wMFzhMW\~S'8n", "", DRIVER_MSSQL).
        
        /*ListMySqlConnections().*/
        RETURN 0.
    END.
    
    METHOD PUBLIC INT ListMySqlConnections():
        FOR EACH MySqlConnections NO-LOCK:
            DISP MySqlConnections.DB_NAME.
        END.
    END.
    
    METHOD PUBLIC INT64 SetDb(iDatabaseConnection AS CHAR):
        RETURN SetDb(iDatabaseConnection, 0).
    END.
    
    METHOD PUBLIC INT64 SetDb(iDatabaseConnection AS CHAR, iTestLevel AS INT64 ):
        IF iDatabaseConnection = DB_NAME OR iDatabaseConnection = DB THEN RETURN 0.
        InitMySqlConnections().
        FIND FIRST MySqlConnections WHERE MySqlConnections.DB_NAME = iDatabaseConnection NO-ERROR.
        IF NOT AVAILABLE MySqlConnections THEN 
         DO:
            IF INDEX(iDatabaseConnection, "/" ) > 0 THEN 
             DO:
                MESSAGE "Unknown database: " iDatabaseConnection. PAUSE 30.
             END.
            RETURN -1.
         END.
        IF SYS_TYPE = SYSTYPE-TEST AND iTestLevel = 0 AND MySqlConnections.DB_TEST <> "" THEN 
            RETURN SetDb(MySqlConnections.DB_TEST, 1).
        
        ASSIGN
            DB_NAME = MySqlConnections.DB_NAME
            DB_HOST = MySqlConnections.DB_HOST
            DB      = MySqlConnections.DB
            DB_USER = MySqlConnections.DB_USER
            DB_PASS = MySqlConnections.DB_PASS
            DRIVER  = MySqlConnections.DB_DRIVER
            .
        RETURN 0.
    END.
    /* to MySql */
    METHOD PUBLIC CHAR ReplicateRecord(iSourceConnection          AS CHAR,  /* 4Gl connection            */
                                       iSourceSchema              AS CHAR, 
                                       iSourceTable               AS CHAR,
                                       iDestinationConnection     AS CHAR,
                                       iDestinationSchema         AS CHAR,
                                       iDestinationTable          AS CHAR,
                                       iRecordId                  AS INT64,
                                       iAction                    AS CHAR,
                                       INPUT-OUTPUT ioUpdateCount AS INT64,
                                       iTableState                AS replTableStateType
                                       ):
        DEF VAR tError AS CHAR NO-UNDO.
        
        IF SetDb(iDestinationConnection) < 0 THEN RETURN "INVALID-MYSQL-CONNECTION".
        IF NOT VALID-OBJECT(cDbProgressRepl) THEN cDbProgressRepl = NEW dbProgressRepl().
        
        tError = cDbProgressRepl:connectDb(iSourceConnection, iSourceSchema).
        IF tError <> "" THEN RETURN tError.
        
        Update_MySql_Table_Record( iSourceSchema, 
                                   iSourceTable,
                                   DB_HOST,
                                   iDestinationSchema,
                                   iDestinationTable,
                                   iRecordId,
                                   iAction,
                                   INPUT-OUTPUT ioUpdateCount,
                                   iTableState
                                  ).
         IF Err THEN RETURN "REPLICATION-ERROR".
         RETURN "".
    END.
    
    /* TODO! The same as in MySql.cls */
    METHOD PUBLIC INT getMaxExtent(iSchema AS CHAR, iTable AS CHAR, iFieldName AS CHAR):
        DEF BUFFER dbSchema FOR dbSchema.
        DEF VAR cntExtent AS INT NO-UNDO.
        
        iFieldName = ENTRY(1, iFieldName, "#") NO-ERROR.       
        IF iFieldName = "" THEN RETURN 0.
        
        FOR EACH dbSchema WHERE dbSchema.schemaName = iSchema 
                            AND dbSchema.tableName  = iTable
                            AND dbSchema.fieldName  BEGINS iFieldName
                            USE-INDEX fieldOrd:
            cntExtent = cntExtent + 1.
        END.
        
        RETURN cntExtent.
    END.
    
    /* TODO! The same as in dbOra.cls */
    METHOD PUBLIC CHAR anyTypeToProgressType (iTypeName AS CHAR):
        CASE iTypeName:
            WHEN "NVARCHAR2" THEN RETURN "CHAR".
            WHEN "VARCHAR2"  THEN RETURN "CHAR".
            WHEN "NVARCHAR"  THEN RETURN "CHAR".
            WHEN "VARCHAR"   THEN RETURN "CHAR".
            WHEN "NUMBER"    THEN RETURN "DECIMAL".
            WHEN "bigint"    THEN RETURN "INT64".
        END.
        RETURN iTypeName.
    END.
    
    /* TODO! The same as in dbOra.cls */
    METHOD PUBLIC HANDLE createTempTableForSchemaTable(iSchema AS CHAR, iTable AS CHAR):
        DEF BUFFER dbSchema FOR dbSchema.
        DEF VAR hSourceTable     AS HANDLE NO-UNDO.
        DEF VAR tExtentFieldName AS CHAR   NO-UNDO.
        DEF VAR tFieldName       AS CHAR   NO-UNDO.
        DEF VAR cntExtent        AS INT    NO-UNDO.
        
        fillDbSchema(iSchema, iTable).
        CREATE TEMP-TABLE hSourceTable.
        FOR EACH dbSchema WHERE dbSchema.schemaName = iSchema 
                            AND dbSchema.tableName  = iTable
                            USE-INDEX fieldOrd:
            IF dbSchema.fieldName BEGINS "U##" OR dbSchema.fieldName BEGINS "PROGRESS_RECID" THEN NEXT.
            
            IF fieldName MATCHES "*##*" AND NOT fieldName BEGINS "U##" THEN
             DO:
                tFieldName = ENTRY(1, dbSchema.fieldName, "#") NO-ERROR.
                IF tExtentFieldName = tFieldName THEN NEXT.
                tExtentFieldName = tFieldName.
                cntExtent = getMaxExtent(iSchema, iTable, tFieldName).
             END.
            ELSE
             DO:
                tFieldName = dbSchema.fieldName.
                cntExtent = 0.
             END.
            
            hSourceTable:ADD-NEW-FIELD(tFieldName, anyTypeToProgressType(fieldType), cntExtent, ?, ?, ?, ?).
            /*MESSAGE "createTempTableForOraTable:" fieldName VIEW-AS ALERT-BOX.*/
        END.
        
        hSourceTable:TEMP-TABLE-PREPARE("ora_" + iTable).
        RETURN hSourceTable.
    END.
    
    /* TODO! The same as in dbOra.cls */
    METHOD PUBLIC CHAR selectFieldList(iSchema AS CHAR, iTable AS CHAR):
        DEF VAR tSql AS CHAR.
        fillDbSchema(iSchema, iTable).
        FOR EACH dbSchema WHERE dbSchema.schemaName = iSchema 
                            AND dbSchema.tableName  = iTable
                            USE-INDEX fieldOrd:
            IF fieldName BEGINS "U##" OR fieldName BEGINS "PROGRESS_RECID" THEN NEXT.
            IF tSql <> "" THEN tSql = tSql + ", ".
            /*
            IF anyTypeToProgressType(fieldType) = "CHAR" THEN
                tSql = tSql + "ASCIISTR(" + fieldName + ") " + fieldName.
            ELSE
            */
                tSql = tSql + fieldName.
        END.
        
        RETURN tSql.
    END.
    
    METHOD PUBLIC CHAR ReplicateRecordFrom(     iSourceConnection      AS CHAR,  /* MySql connection            */
                                                iSourceSchema          AS CHAR,  /* MySql Db/Schema             */
                                                iSourceTable           AS CHAR,  /* MySql Table                 */
                                                iDestinationConnection AS CHAR,  /* Destination 4Gl connection  */
                                                iDestinationSchema     AS CHAR,  /* progress db/SCHEMA          */
                                                iDestinationTable      AS CHAR,  /* progress Table              */
                                                iRecordId              AS INT64, /* Id                          */
                                                iAction                AS CHAR,  /* do: INSERT/UPDATE/DELETE    */
                                   INPUT-OUTPUT ioUpdateCount          AS INT64
                                              ):
        DEF VAR tError                    AS CHAR    NO-UNDO.
        DEF VAR tDestinationTable         AS CHAR    NO-UNDO.
        DEF VAR hSourceTable              AS HANDLE  NO-UNDO.
        DEF VAR hSourceBuffer             AS HANDLE  NO-UNDO.
        DEF VAR hDestinationBuffer        AS HANDLE  NO-UNDO.
        DEF VAR tSql                      AS CHAR    NO-UNDO.
        
        IF SetDb(iSourceConnection) <> 0 THEN RETURN "UNKNOWN_SQL_CONNECTION".
        
        IF NOT VALID-OBJECT(cDbProgressRepl) THEN cDbProgressRepl = NEW dbProgressRepl().
        
        tError = cDbProgressRepl:connectDb(iDestinationConnection, iDestinationSchema).
        IF tError <> "" THEN RETURN tError.
        
        recordCount = 0.
        tDestinationTable = iDestinationSchema + "." + iDestinationTable. /* PROGRESS */
        CREATE BUFFER hDestinationBuffer FOR TABLE tDestinationTable. 
        hSourceTable = createTempTableForSchemaTable(iSourceSchema, iSourceTable).
        IF NOT VALID-HANDLE(hSourceTable) THEN RETURN "CAN_NOT_CREATE_TEMPTABLE_FOR_SOURCE_TABLE".
        hSourceBuffer = hSourceTable:DEFAULT-BUFFER-HANDLE.
        
        tSql = "SELECT ".
        IF DRIVER = DRIVER_MSSQL THEN tSql = "SELECT TOP " + STRING(MaxRecordCounter) + " ".
       
        tSql = tSql + selectFieldList(iSourceSchema, iSourceTable) + " FROM " + iSourceTable .
                
        tSql = tSql + " WHERE ".
        IF iRecordId > 0 THEN 
            tSql = tSql + " id = " + STRING(iRecordId).
        ELSE
            tSql = tSql + " updateCount > " + STRING(ioUpdateCount).
        
        tSql = tSql + " ORDER BY updateCount".
        
        IF DRIVER = DRIVER_MYSQL THEN tSql = tSql + " LIMIT " + STRING(MaxRecordCounter) + " ".        
        IF InsertIntoTempTable (iSourceSchema, tSql, TABLE-HANDLE hSourceTable BIND) <> "" THEN RETURN "ERROR_INSERTING_DATA_FROM_ORACLE".
        
        
        cDbProgressRepl:DISABLE_UTF_CORRECTION = TRUE.
        
        tError = cDbProgressRepl:ReplicateRecord(iSourceConnection,
                                                "TEMP-TABLE",          /* progress Db              */
                                                hSourceTable:NAME,       /* progress Table           */
                                                hSourceBuffer,
                                                iDestinationConnection,  /* Destination connection   */
                                                iDestinationSchema,      /* progress/ora db/SCHEMA            */
                                                iDestinationTable,       /* progress/ora Table                */
                                                iRecordId,               /* Id                       */
                                                iAction,                 /* do: INSERT/UPDATE/DELETE */
                                   INPUT-OUTPUT ioUpdateCount).
        IF tError <> "" THEN RETURN tError.
        recordCount = cDbProgressRepl:recordCount.
        
        IF iSourceTable =  "REPLICATION_DELETE" OR iDestinationTable = "REPLICATION_DELETE" THEN
         DO:
            tSql = 'DELETE FROM ' + iSourceTable + ' WHERE UpdateCount < ' + STRING(ioUpdateCount).
            IF EXECUTE(iSourceSchema, tSql) < 0 THEN tError = "CAN_NOT_DELETE_FROM_SOURCE".
            
            MESSAGE "Replication delete support: " tSql.
         END.
         
        RETURN tError.
    END.
    
END CLASS.
