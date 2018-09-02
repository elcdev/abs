CLASS fieldEditForm: /* INHERITS baseForm:*/
    DEFINE VARIABLE fieldValue        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE fieldDefaultValue AS CHARACTER NO-UNDO INITIAL "".
    DEFINE VARIABLE fieldType         AS CHARACTER NO-UNDO INITIAL "CHAR".
    DEFINE VARIABLE fieldTop          AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldLeft         AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldWidth        AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE fieldHeight       AS DECIMAL   NO-UNDO INITIAL 1.
    DEFINE VARIABLE fieldPfColor      AS DECIMAL   NO-UNDO INITIAL 7.
    DEFINE VARIABLE fieldDColor       AS DECIMAL   NO-UNDO INITIAL 7.
    DEFINE VARIABLE fieldDataList     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE fieldState        AS CHARACTER NO-UNDO INITIAL "NOT-CHANGED".
    
    DEFINE VARIABLE editorMode    AS CHARACTER NO-UNDO INITIAL "". /* = "ReadOnly"*/
    DEFINE VARIABLE hWidget       AS HANDLE    NO-UNDO.
    
    DEFINE VARIABLE systemSettings AS systemSettingsApi NO-UNDO.
    DEFINE VARIABLE cStr           AS stringApi NO-UNDO.
    DEFINE VARIABLE cClr           AS sysColors NO-UNDO. 
    DEFINE VARIABLE cFso           AS fileSystemObject NO-UNDO.
    
    DEF VAR Field_Delimiter AS CHAR INIT "|".
    DEF VAR Null_Value      AS CHAR INIT "(null)".
    DEF VAR oldValue        AS CHAR.
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
    DEF VAR ENABLE-SHADOW   AS LOG INITIAL FALSE.
    DEF VAR IsOk             AS LOG.
    DEF VAR Prg_Ex           AS INT64.
    
    DEFINE FRAME formFrame
      WITH NO-LABEL SIZE 10 BY 1 OVERLAY NO-BOX COL 1 ROW 1.

    DEFINE FRAME shadowFrame
      WITH NO-LABEL SIZE 10 BY 1 OVERLAY NO-BOX COL 1 ROW 1.
    
    
    CONSTRUCTOR fieldEditForm():
        systemSettings = NEW systemSettingsApi().
        cStr           = NEW stringApi().
        cClr           = NEW sysColors().
        cFso           = NEW fileSystemObject().
    END.
    
    DESTRUCTOR fieldEditForm():
        DELETE OBJECT systemSettings NO-ERROR.
        DELETE OBJECT cStr           NO-ERROR.
        DELETE OBJECT cClr           NO-ERROR.
        DELETE OBJECT cFso           NO-ERROR.
    END.
    
    {propertyGetSetForField.f &name="width" &type="dec" &field="fieldWidth"}
    {propertyGetSetForField.f &name="height" &type="dec" &field="fieldHeight"}
    {propertyGetSetForField.f &name="top" &type="dec" &field="fieldTop"}
    {propertyGetSetForField.f &name="left" &type="dec" &field="fieldLeft"}
    {propertyGetSetForField.f &name="value" &type="char" &field="fieldValue"}
    {propertyGetSetForField.f &name="state" &type="char" &field="fieldState"}

        
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
            IF fieldPfColor = 0 AND OPSYS = "unix" THEN
                  fieldPfColor = cclr:getColorNumber(systemSettings:getValueChar(f_Prp_ID,
                                                 "HELP-PROC-SLCLR")).
            HELP-PROC-NAME = systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-NAME").
            IF HELP-PROC-NAME <> "" THEN 
             DO:
                HELP-PROC-AUTO = systemSettings:getValueInt64(f_Prp_ID, "HELP-PROC-AUTO").
                
                /* Задаем список значений по полю */
                IF fieldDataList = "" THEN
                    HELP-PROC-DATA = systemSettings:getValueChar(f_Prp_ID, "HELP-PROC-DATA").
                ELSE
                    HELP-PROC-DATA = fieldDataList.
                
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
                HELP-PROC-TOP    = systemSettings:getValueInt64(f_Prp_ID, "HELP-PROC-TOP").
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
                    
                    DisableForm().
                    IF HELP-PROC-NAME = "p_field_ls" THEN
                     DO:
                        MESSAGE "TODO! Opening list ...". PAUSE 10.
                        /*
                        RUN p_field_ls.p(INPUT-OUTPUT fieldValue,
                                         INPUT-OUTPUT fieldState,
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
                                         */
                     END.
                    ELSE
                     DO:
                      RUN VALUE(HELP-PROC-NAME)(HELP-PROC-TOP,   HELP-PROC-LEFT,
                                              HELP-PROC-WIDTH, HELP-PROC-HEIGHT,
                                              HELP-PROC-BGCLR, HELP-PROC-SLCLR,
                                              HELP-PROC-SHCLR, HELP-PROC-BXCLR,
                                              HELP-PROC-DATA,  INPUT-OUTPUT fieldValue,
                                              OUTPUT IsOk).
                     END.
                    IF IsOk THEN fieldState = "".
                    
                    HideForm().
                    RETURN "".
                 END.
             END.
            /*systemSettings:EnableSystemWarnings().*/
         END.
        ELSE
         DO:
            fieldPfColor = 10.
         END.
         


        
        FRAME formFrame:WIDTH    = mf_Width.
        FRAME formFrame:Height   = mf_Height.
        FRAME formFrame:COL      = mf_Left.
        FRAME formFrame:ROW      = mf_Top.

        hWidget            = CreateField(   fieldType, 
                                            fieldValue, 
                                            FRAME formFrame:HANDLE, 
                                            1, 
                                            1,
                                            mf_Width,
                                            mf_Height).
        hWidget:DCOLOR  = fieldDColor.
        
        IF OPSYS = "unix" THEN hWidget:PFCOLOR = fieldPfColor.
        IF editorMode = "ReadOnly" THEN
         DO:    
            hWidget:SENSITIVE  = False.
         END.

        RETURN "".
    END.
	
    METHOD PUBLIC CHARACTER InitShadowForm():
        
        FRAME shadowFrame:WIDTH    = FRAME formFrame:WIDTH.
        FRAME shadowFrame:Height   = FRAME formFrame:height.
        FRAME shadowFrame:COL      = FRAME formFrame:COLUMN + 2.
        FRAME shadowFrame:ROW      = FRAME formFrame:ROW  + 1.
		
        RETURN "".
    END.
    
    METHOD PUBLIC CHARACTER ShowList():
        IF cfso:FindFile(INPUT-OUTPUT HELP-PROC-NAME) <> "" THEN RETURN "".
        DisableForm().
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
                                  HELP-PROC-DATA,  INPUT-OUTPUT fieldValue,
                                  OUTPUT IsOk).
         END.
        IF IsOk THEN fieldState = "".
    END.

    ON PF2, F2 OF FRAME formFrame
     DO:
        ShowList().
        ShowFrame().
     END.
     
    ON GO, RETURN OF FRAME formFrame
     DO:
        IF editorMode = "" OR editorMode = "2" THEN
         DO:
            fieldValue  = hWidget:SCREEN-VALUE.
            IF fieldValue = Null_Value THEN fieldValue = "".
            IF fieldValue <> oldValue  THEN fieldState = "".
         END.
     END.

    ON PF4, F4, END-ERROR OF FRAME formFrame
     DO:
        DEF VAR fl   AS INT64.
        HideForm().
        /*
        IF fl = 0 THEN 
         DO:
            APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
         END.
        */
     END.
     
    METHOD PUBLIC VOID ShowData():
        
    END.

    METHOD PUBLIC CHARACTER recordset():
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

    METHOD PUBLIC CHAR DisableForm():
        DISABLE ALL WITH FRAME formFrame.  PAUSE 0.
        DISABLE ALL WITH FRAME formShadow. PAUSE 0.
        RETURN "".
    END.

    METHOD PUBLIC CHAR HideForm():
        HIDE FRAME formFrame.  PAUSE 0.
        HIDE FRAME formShadow. PAUSE 0.
        RETURN "".
    END.
    
    METHOD PUBLIC CHAR ShowFrame():
        IF ENABLE-SHADOW THEN 
         DO:
            VIEW FRAME formShadow. PAUSE 0. 
         END.
         
        VIEW FRAME formFrame.  PAUSE 0.
        ShowData().
        
        RETURN "".
    END.

	METHOD PUBLIC VOID ShowForm():
        InitForm().
        InitShadowForm().
        ShowFrame().
    
        oldValue = fieldValue.

        IF editorMode = "2" THEN 
         DO:
            hWidget:AUTO-ZAP=False.
            hWidget:CURSOR-OFFSET = 2.
            
            APPLY "INSERT-MODE" TO FOCUS.
            APPLY "LEFT-ARROW" TO FOCUS.
            APPLY "END" TO FOCUS.
         END.
     
        IF Prg_Ex = 0 AND (editorMode = "" OR editorMode = "1" OR editorMode = "2") THEN
         DO:
            IF editorMode = "2" THEN
                APPLY "INSERT".
                
            ON PF4 END-ERROR.       
            WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4, RETURN, GO OF FRAME formFrame.
        
            IF editorMode = "" OR editorMode = "2" THEN
             DO:
                fieldValue  = hWidget:SCREEN-VALUE.
                IF fieldValue = Null_Value THEN fieldValue = "".
                IF fieldValue <> oldValue  THEN fieldState = "".
             END.
         
            HideForm().
            DELETE WIDGET hWidget.
         END.
        
    END. 
END.


