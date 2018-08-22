CLASS fieldEditForm INHERITS baseForm:
    DEFINE VARIABLE fieldValue   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE fieldType    AS CHARACTER NO-UNDO INITIAL "CHAR".
    DEFINE VARIABLE fieldTop     AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldLeft    AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldWidth   AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldHeight  AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldPfColor AS DECIMAL   NO-UNDO.
    
    DEFINE VARIABLE hWidget    AS HANDLE    NO-UNDO.
    
    DEFINE VARIABLE systemSettings AS systemSettingsApi NO-UNDO.
    DEFINE VARIABLE cStr           AS stringApi NO-UNDO.
    DEFINE VARIABLE cClr           AS sysColors NO-UNDO. 
    DEF VAR settingsKey            AS CHAR      NO-UNDO INIT "/System/DataTypes/".
    
    DEF VAR HELP-PROC-NAME  AS CHAR.
    DEF VAR HELP-PROC-AUTO  AS INT64.
    DEF VAR HELP-PROC-DATA  AS CHAR.

    DEF VAR HELP-PROC-BGCLR AS INT64.
    DEF VAR HELP-PROC-BXCLR AS INT64.
    DEF VAR HELP-PROC-SHCLR AS INT64.
    DEF VAR HELP-PROC-SLCLR AS INT64.

    DEF VAR HELP-PROC-TOP    AS INT64.
    DEF VAR HELP-PROC-LEFT   AS INT64.
    DEF VAR HELP-PROC-HEIGHT AS INT64.
    DEF VAR HELP-PROC-WIDTH  AS INT64.
    DEF VAR HELP-PROC-LTYPE  AS INT64.
    DEF VAR IsOk             AS LOG.
    
    DEFINE FRAME formFrame
      WITH NO-LABEL SIZE 10 BY 1 OVERLAY NO-BOX COL 1 ROW 1.
    
    CONSTRUCTOR fieldEditForm():
        systemSettings = NEW systemSettingsApi().
        cStr           = NEW stringApi().
        cClr           = NEW sysColors().
    END.
    
    DESTRUCTOR fieldEditForm():
        DELETE OBJECT systemSettings NO-ERROR.
        DELETE OBJECT cStr           NO-ERROR.
        DELETE OBJECT cClr           NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER InitForm():
        DEF VAR S_W       AS INT64 NO-UNDO.
        DEF VAR S_H       AS INT64 NO-UNDO.
        DEF VAR mf_Top    AS DEC INIT 5.
        DEF VAR mf_Left   AS DEC INIT 10. 
        DEF VAR mf_Width  AS DEC INIT 60.
        DEF VAR mf_Height AS DEC INIT 14.
        DEF VAR f_Prp_ID  AS INT64 NO-UNDO.

        S_W = CURRENT-WINDOW:WIDTH.
        S_H = CURRENT-WINDOW:HEIGHT.
        
        /* Initialize window position */
        IF fieldType = "" THEN fieldType = "CHAR".
        f_Prp_ID = systemSettings:getKeyId(settingsKey + fieldType).
        
        If f_Prp_Id > 0 THEN
         DO:
            IF fieldWidth = 0 THEN
             DO:
                fieldWidth = 8.
                fieldWidth = systemSettings:getValueInt64(f_Prp_ID, "WIDTH").
             END.
            IF fieldHeight = 0 THEN
             DO:
                fieldHeight = 1.
                fieldHeight = systemSettings:getValueInt64(f_Prp_ID, "HEIGHT").
             END.

            IF fieldHeight <= 0 THEN fieldHeight = 1.
            IF fieldWidth  <= 0 THEN fieldWidth  = 8.
         END.
        mf_Top      = fieldTop.
        mf_Left     = fieldLeft.
        mf_Width    = fieldWidth.
        mf_Height   = fieldHeight.
        
        IF mf_Height <= 0 THEN mf_Height = 1.
        IF mf_Width  <= 0 THEN mf_Width  = 8.
        

        mf_Width = fieldWidth.
        mf_Height= fieldHeight.
        
        If f_Prp_Id > 0 THEN
         DO:
            IF fieldPfColor = 0 THEN
                  fieldPfColor = cclr:getColorNumber(systemSettings:getValueChar(f_Prp_ID,
                                                 "HELP-PROC-SLCLR")).
            HELP-PROC-NAME = systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-NAME").
            IF HELP-PROC-NAME <> "" THEN 
             DO:
                HELP-PROC-AUTO = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-AUTO").
                
                /* Задаем список значений по полю */
                IF f_DataList = "" THEN
                    HELP-PROC-DATA = systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-DATA").
                ELSE
                    HELP-PROC-DATA = f_DataList.
                
                /* Цвет фона */
                HELP-PROC-BGCLR = 
                 cclr:getColorNumber(systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-BGCLR")).
                /* Цвет рамки */
                HELP-PROC-BXCLR = 
                 cclr:getColorNumber(systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-BXCLR")).
                /* Цвет тени окна */
                HELP-PROC-SHCLR = 
                 cclr:getColorNumber(systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-SHCLR")).
                /* Цвет курсора */
                HELP-PROC-SLCLR = fieldPfColor.
                /* Позиция окна Y */
                HELP-PROC-TOP    = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-TOP").
                IF HELP-PROC-TOP = 0 THEN HELP-PROC-TOP = fieldTop.
                /* Позиция окна X */
                HELP-PROC-LEFT   = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-LEFT").
                IF HELP-PROC-LEFT = 0 THEN HELP-PROC-LEFT = fieldLeft.
                /* Высота окна */
                HELP-PROC-HEIGHT = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-HEIGHT").
                IF HELP-PROC-HEIGHT = 0 THEN HELP-PROC-HEIGHT = mf_Height.
                /* Ширина окна */
                HELP-PROC-WIDTH  = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-WIDTH").
                HELP-PROC-LTYPE  = 1.
                HELP-PROC-LTYPE  = systemSettings:getValueInt(f_Prp_ID, "HELP-PROC-LTYPE").
                                    
                IF HELP-PROC-WIDTH = 0 THEN HELP-PROC-WIDTH = mf_Width.

                /* Коррекция позиционирования окна */
                IF HELP-PROC-TOP    <= 0  THEN HELP-PROC-TOP    = 1.
                IF HELP-PROC-TOP    > S_H THEN HELP-PROC-TOP    = S_H.
                IF HELP-PROC-LEFT   < 1   THEN HELP-PROC-LEFT   = 1.
                IF HELP-PROC-LEFT   > S_W THEN HELP-PROC-LEFT   = S_W.
                IF HELP-PROC-HEIGHT < 4   THEN HELP-PROC-HEIGHT = 4.
                IF HELP-PROC-HEIGHT > S_H THEN HELP-PROC-HEIGHT = S_H.
                IF HELP-PROC-WIDTH  < 4   THEN HELP-PROC-WIDTH  = 4.
                IF HELP-PROC-WIDTH  > S_W THEN HELP-PROC-WIDTH  = S_W.
                
                IF HELP-PROC-TOP + HELP-PROC-HEIGHT > S_H THEN
                 DO:        
                    IF HELP-PROC-HEIGHT > S_H THEN HELP-PROC-HEIGHT = S_H.                           IF HELP-PROC-TOP - HELP-PROC-HEIGHT > 0 THEN
                     DO:
                        HELP-PROC-TOP = HELP-PROC-TOP - HELP-PROC-HEIGHT.
                     END.
                    ELSE
                     DO:
                        HELP-PROC-TOP = S_H - HELP-PROC-HEIGHT + 1. 
                     END.
                 END.
                 
                IF HELP-PROC-AUTO = 1 THEN
                 DO:
                    Prg_Ex = 1.
                    
                    RUN DisableMf.
                    IF HELP-PROC-NAME = "p_field_ls" THEN
                     DO:
                        /*MESSAGE "Opening list ...".*/
                        RUN p_field_ls.p(INPUT-OUTPUT f_Vl,
                                         INPUT-OUTPUT f_Chg,
                                         HELP-PROC-DATA,
                                         STRING(HELP-PROC-LEFT)   + "|" +
                                         STRING(HELP-PROC-TOP)    + "|" +
                                         STRING(HELP-PROC-WIDTH)  + "|" +
                                         STRING(HELP-PROC-HEIGHT) + "|" +
                                         STRING("")               + "|" +
                                         STRING(HELP-PROC-LTYPE)  + "|" +
                                         STRING(HELP-PROC-BGCLR)  + "|" +
                                         STRING(HELP-PROC-SLCLR)  + "|" +
                                         STRING(HELP-PROC-BXCLR)  + "|" + 
                                         STRING(HELP-PROC-SHCLR)  + "|"
                                         ).
                     END.
                    ELSE
                     DO:
                      RUN VALUE(HELP-PROC-NAME)(HELP-PROC-TOP,   HELP-PROC-LEFT,
                                              HELP-PROC-WIDTH, HELP-PROC-HEIGHT,
                                              HELP-PROC-BGCLR, HELP-PROC-SLCLR,
                                              HELP-PROC-SHCLR, HELP-PROC-BXCLR,
                                              HELP-PROC-DATA,  INPUT-OUTPUT f_Vl,
                                              OUTPUT IsOk).
                     END.
                    IF IsOk THEN f_Chg = 1.
                    
                    RUN HideMf.
                    RETURN.
                 END.
             END.
            systemSettings:EnableSystemWarnings().
         END.
        ELSE
         DO:
            fieldPfColor = 10.
         END.
         


        FRAME formFrame:WIDTH    = mf_Width.
        FRAME formFrame:Height   = mf_Height.
        FRAME formFrame:COL      = mf_Left.
        FRAME formFrame:ROW      = mf_Top.

        hWidget              = Create_Field(   fieldType, 
                                            f_Vl, 
                                            FRAME formFrame:HANDLE, 
                                            1, 
                                            1,
                                            mf_Width,
                                            mf_Height).
        hWidget:DCOLOR  = f_DCOLOR.
        hWidget:PFCOLOR = fieldPfColor.
        IF f_Mode = 5 THEN
         DO:    
            hWidget:SENSITIVE  = False.
         END.

        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER ShowList():
        IF cfso:FindFile(INPUT-OUTPUT HELP-PROC-NAME) = 1 THEN LEAVE.
        RUN DisableMf.
        IsOk = No.
        IF HELP-PROC-NAME = "r_field_ls" THEN
         DO:
            /*
            RUN r_field_ls.p(INPUT-OUTPUT f_Vl,
                             INPUT-OUTPUT f_Chg,
                             HELP-PROC-DATA,
                             STRING(HELP-PROC-LEFT)   + "|" +
                             STRING(HELP-PROC-TOP)    + "|" +
                             STRING(HELP-PROC-WIDTH)  + "|" +
                             STRING(HELP-PROC-HEIGHT) + "|" +
                             STRING("")               + "|" +
                             STRING(HELP-PROC-LTYPE)  + "|" +
                             STRING(HELP-PROC-BGCLR)  + "|" +
                             STRING(HELP-PROC-SLCLR)  + "|" +
                             STRING(HELP-PROC-BXCLR)  + "|"
                             ).
            */
         END.
        ELSE
         DO:
          RUN VALUE(HELP-PROC-NAME)(HELP-PROC-TOP,   HELP-PROC-LEFT,
                                  HELP-PROC-WIDTH, HELP-PROC-HEIGHT,
                                  HELP-PROC-BGCLR, HELP-PROC-SLCLR,
                                  HELP-PROC-SHCLR, HELP-PROC-BXCLR,
                                  HELP-PROC-DATA,  INPUT-OUTPUT f_Vl,
                                  OUTPUT IsOk).
         END.
        IF IsOk THEN f_Chg = 1.
    END.

    ON PF2, F2 OF FRAME formFrame
     DO:
        RUN Show_List.
        ShowMf.
     END.
     
    ON GO OF FRAME formFrame 
     DO:
        IF f_Mode = 0 OR f_Mode = 2 THEN
         DO:
            f_Vl  = ctrl:SCREEN-VALUE.
            IF f_Vl = f_Null_Value THEN f_Vl = "".
            IF f_Vl <> f_Vl_Old THEN f_Chg = 1.
         END.
     END.

    ON PF4, F4, END-ERROR OF FRAME formFrame
     DO:
        HideMf().
        IF fl = 0 THEN 
         DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
         END.
     END.
     
    METHOD PUBLIC VOID ShowData():
        ENABLE fieldValue WITH FRAME formFrame. 
        PAUSE 0.
    END.

    METHOD PUBLIC CHARACTER recordset():
        RETURN "".
    END.
    
    ON RETURN OF fieldValue
     DO:

        RETURN "".
     END.
    
    METHOD WIDGET-HANDLE createField (fieldType AS CHAR, 
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
        DEF VAR f_Prp_Id    AS INT64.
        DEF VAR f_PrId      AS INT64.
        DEF VAR f_Auto_Format  AS INT64.
        DEF VAR f_Str       AS CHAR.
        DEF VAR ctrl        AS WIDGET-HANDLE.
        
        f_Value  = f_Vl.
        IF fieldType = "" THEN fieldType = "CHAR".
        f_Prp_ID = systemSettings:getKeyId(settingsKey + fieldType).
        If f_Prp_Id > 0 THEN
         DO:
            /*systemSettings:DisableSystemWarnings().*/
            f_Str = systemSettings:getValueChar(f_Prp_ID, "DATA-TYPE").
            IF f_Str <> "" THEN f_Data_Type = f_Str.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "AUTO-FORMAT").
            IF f_Str <> "" THEN f_Auto_Format = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "FORMAT").
            IF f_Str <> "" THEN f_Format = f_Str.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "WIDTH").
            IF f_Str <> "" THEN f_WIDTH  = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "HEIGHT").
            IF f_Str <> "" THEN f_HEIGHT = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "COL").
            IF f_Str <> "" THEN f_COL    = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "ROW").
            IF f_Str <> "" THEN f_ROW    = int64(f_Str) NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "HELP").
            IF f_Str <> "" THEN f_HELP    = f_Str NO-ERROR.
            f_Str = systemSettings:getValueChar(f_Prp_ID, "DEFAULT").

            IF SUBSTRING(f_Str,1,1) = "=" AND f_Vl = "" THEN
             DO:
                f_Str = Replace(f_Str, "year(today)", cstr:CFormat(today,"yyyy")).
                f_Str = Replace(f_Str, "month(today)",cstr:CFormat(today,"mm")).
                f_Str = Replace(f_Str, "today",cstr:CFormat(today,"dd.mm.yyyy")).
                f_Str = SUBSTRING(f_Str,2).
             END.
            IF f_Str <> "" AND f_Vl = "" THEN f_Value   = f_Str.
            /*systemSettings:EnableSystemWarnings().*/
         END.
        IF f_C > 0 THEN f_Col   = f_C.
        IF f_R > 0 THEN f_Row   = f_R.
        IF f_W > 0 THEN f_Width = f_W.
        IF f_H > 0 THEN f_Height= f_H.
        
        IF f_Data_Type = "EDITOR" THEN
         DO:
            CREATE EDITOR ctrl.
            ctrl:BUFFER-CHARS = 200.
            ctrl:INNER-LINES  = f_Height.
            ctrl:INNER-CHARS  = f_Width.
         END.
        ELSE
         DO:
            CREATE FILL-IN ctrl.
            ctrl:DATA-TYPE = f_Data_Type.
            ctrl:Format    = f_Format.
            ctrl:Width     = f_Width.
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
