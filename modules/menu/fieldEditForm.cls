CLASS fieldEditForm INHERITS baseForm:
    DEFINE VARIABLE fieldValue AS CHARACTER NO-UNDO.
    DEFINE VARIABLE fieldType  AS CHARACTER NO-UNDO INITIAL "CHAR".
    DEFINE VARIABLE fieldRow   AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldCol   AS DECIMAL   NO-UNDO.
    
    DEFINE VARIABLE hWidget    AS HANDLE    NO-UNDO.
    
    DEFINE VARIABLE systemSettings AS systemSettingsApi.
    
    DEFINE FRAME formFrame
        formBrowse HELP " " SKIP
      WITH NO-LABELS SIZE 45 BY 15 OVERLAY ROW 4
      CENTERED.
    
    CONSTRUCTOR menuEditForm():
        systemSettings = NEW systemSettingsApi().
    END.
    
    DESTRUCTOR menuEditForm():
        DELETE OBJECT systemSettings NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER InitForm():
        CREATE FILL-IN hWidget ASSIGN 
            ROW = fieldRow
            COLUMN = fieldCol
            .
        RETURN "".
    END.
    
    METHOD PUBLIC VOID ShowData():
        ENABLE formBrowse WITH FRAME formFrame. 
        PAUSE 0.
    END.

    METHOD PUBLIC CHARACTER recordset():
        RETURN "".
    END.
    
    ON RETURN OF fieldValue
     DO:

        RETURN "".
     END.
    
    METHOD createField RETURNS WIDGET-HANDLE (f_DTP AS CHAR, 
                                              f_Vl AS CHAR, 
                                              Mf AS WIDGET-HANDLE,
                                              f_C AS INT64,
                                              f_R AS INT64,
                                              f_W AS DEC,
                                              f_H AS DEC):
        DEF VAR f_Format    AS CHAR INIT "X(200)".
        DEF VAR f_Value     AS CHAR INIT "".
        DEF VAR f_Data_Type AS CHAR INIT "CHARACTER".
        DEF VAR f_Width     AS INT64  INIT 40.
        DEF VAR f_Height    AS INT64  INIT 1.
        DEF VAR f_Col       AS INT64  INIT 16.
        DEF VAR f_Row       AS INT64  INIT 8.
        DEF VAR f_Help      AS CHAR INIT " ".
        DEF VAR f_Key       AS CHAR INIT "/SoftWare/Programm/DataTypes/".
        DEF VAR f_Prp_Id    AS INT64.
        DEF VAR f_PrId      AS INT64.
        DEF VAR f_Auto_Format  AS INT64.
        DEF VAR f_Str       AS CHAR.
        DEF VAR ctrl        AS WIDGET-HANDLE.
        f_Value  = f_Vl.
        IF f_DTP = "" THEN f_DTP = "CHAR".
        f_Prp_ID = systemSettings:GetRegId(f_Key + f_DTP).
        If f_Prp_Id > 0 THEN
         DO:
            systemSettings:DisableSystemWarnings().
            f_Str = systemSettings:Gt(f_Prp_ID, "DATA-TYPE").
            IF f_Str <> "" THEN f_Data_Type = f_Str.
            f_Str = systemSettings:Gt(f_Prp_ID, "AUTO-FORMAT").
            IF f_Str <> "" THEN f_Auto_Format = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "FORMAT").
            IF f_Str <> "" THEN f_Format = f_Str.
            f_Str = systemSettings:Gt(f_Prp_ID, "WIDTH").
            IF f_Str <> "" THEN f_WIDTH  = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "HEIGHT").
            IF f_Str <> "" THEN f_HEIGHT = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "COL").
            IF f_Str <> "" THEN f_COL    = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "ROW").
            IF f_Str <> "" THEN f_ROW    = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "HELP").
            IF f_Str <> "" THEN f_HELP    = f_Str NO-ERROR.
            f_Str = systemSettings:Gt(f_Prp_ID, "DEFAULT").
            /*MESSAGE "Ok " f_HEIGHT f_H VIEW-AS ALERT-BOX.*/
            IF SUBSTRING(f_Str,1,1) = "=" AND f_Vl = "" THEN
             DO:
                f_Str = Replace(f_Str, "year(today)", cstr:CFormat(today,"yyyy")).
                f_Str = Replace(f_Str, "month(today)",cstr:CFormat(today,"mm")).
                f_Str = Replace(f_Str, "today",cstr:CFormat(today,"dd.mm.yyyy")).
                f_Str = SUBSTRING(f_Str,2).
             END.
            IF f_Str <> "" AND f_Vl = "" THEN f_Value   = f_Str.
            systemSettings:EnableSystemWarnings().
         END.
        IF f_C > 0 THEN f_Col   = f_C.
        IF f_R > 0 THEN f_Row   = f_R.
        IF f_W > 0 THEN f_Width = f_W.
        IF f_H > 0 THEN f_Height= f_H.
        
        IF f_Data_Type = "EDITOR" THEN
         DO:
            CREATE EDITOR ctrl.
            ctrl:BUFFER-CHARS = 200.
            /*ctrl:Height       = f_Height.*/
            ctrl:INNER-LINES  = f_Height.
            ctrl:INNER-CHARS  = f_Width.
    /*        ctrl:Width        = f_Width.*/
            MESSAGE "OOOOOOOOO".
         END.
        ELSE
         DO:
            CREATE FILL-IN ctrl.
            ctrl:DATA-TYPE = f_Data_Type.
            ctrl:Format    = f_Format.
            ctrl:Width     = f_Width.
            /*IF Mode = 1 THEN*/ 
            /*ctrl:AUTO-GO = TRUE.*/
         END.
        ctrl:FRAME        = Mf:HANDLE.
        ctrl:Visible      = True.
        ctrl:Col          = f_Col.
        ctrl:Row          = f_Row.
        ctrl:Screen-Value = f_Value.
        ctrl:Sensitive    = True.
        ctrl:HELP         = f_Help.
        
        PAUSe 0 BEFORE-HIDE.
        RETURN ctrl.
    END.

END.
