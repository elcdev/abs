/*
    AUTH:   ALEZHU
    DATE:   24.09.2004
    DESC:   Print manager for PLATON
*/
DEF INPUT PARAMETER f_FileName AS CHAR.
DEF INPUT PARAMETER f_Param    AS CHAR.
PAUSE 0 BEFORE-HIDE.
{global.i}
/*  "e1 | e2 | e3 | e4 | e5 | e6 | e7 | e8"
    f_Param - Delimited parameters string (delimiter - [|]):
       element 1 - kod printera (e,p,f, ...) - pozicionirovanie kursora.
       element 2 - enter the printer on open [autoopen]/[nodialog]
       element 3 - new delimiter (EXCEL)
       element 4 - output file name mask 
       element 5 - set convertation code [-1] - NO CENVERTION
       element 6 - list keys of enabled printers [EX]=[EKRAN|EXCEL]
       element 7 - leave file without deletion (1)
       element 8 - run log_wrt(1,logstr).
       element 9 - s_lginfo(rptyp;cif;beg_dat;end_dat;g-fname;output_to)
*/                  
DEF VAR f_X        AS INT64 NO-UNDO INIT 21.
DEF VAR f_Y        AS INT64 NO-UNDO INIT 7.
DEF VAR Txt_Viewer AS CHAR NO-UNDO.
DEF VAR f_DisDelete AS CHAR NO-UNDO. /* Disable file deletion on exit <> "" */
DEF VAR cuni as sysuni.
DEF VAR csys AS sysc.
DEF VAR cprf AS sysprf.
DEF VAR cbnk AS sysbnk.
cuni = new sysuni().
cprf = new sysprf().
csys = new sysc().
cbnk = new sysbnk().
FUNCTION DELETE_OBJECTS INT():
    /* Udaljajem vhodjashij fail */
   IF VALID-OBJECT(cprf) AND f_DisDelete = "" THEN cprf:cfso:Sys_Delete_File(f_FileName).
    DELETE OBJECT cuni NO-ERROR.
    DELETE OBJECT cprf NO-ERROR.
    DELETE OBJECT csys NO-ERROR.
    DELETE OBJECT cbnk NO-ERROR.
END.
DEF VAR Cmd AS CHAR NO-UNDO.
DEF VAR MF_HEIGHT   AS DEC  NO-UNDO INIT 12.
DEF VAR MF_WIDTH    AS DEC  NO-UNDO INIT 37.
DEF VAR MF_TITL     AS CHAR NO-UNDO.
MF_TITL = " Izvads uz: ".
DEF VAR MF_LEFT     AS DEC   NO-UNDO INIT 16.
DEF VAR MF_TOP      AS DEC   NO-UNDO INIT 5.
DEF VAR f_Id        AS CHAR  NO-UNDO.
DEF VAR f_Name      AS CHAR  NO-UNDO.
DEF VAR t_Id        AS INT64 NO-UNDO.
DEF VAR t_Name      AS CHAR  NO-UNDO.
DEF VAR t_Val       AS CHAR  NO-UNDO.
DEF VAR ei_Id       AS INT64 NO-UNDO.
DEF VAR f_Ext_Pref  AS CHAR  NO-UNDO.
DEF VAR f_Chg       AS INT64 NO-UNDO.
DEF VAR local       AS LOG   NO-UNDO.
DEF VAR f_EnPrint   AS CHAR  NO-UNDO.
DEF VAR f_logstr    AS CHAR  NO-UNDO.
DEF VAR f_newlogstr    AS CHAR  NO-UNDO.
DEF VAR f_ParamList AS CHAR NO-UNDO. /*list delimiter ':'*/
DEF VAR f_Laser     AS CHAR  NO-UNDO.
DEF VAR f_EXISTTHCV AS CHAR  NO-UNDO. 
f_EXISTTHCV = search("/bank/platon/bin/thcv").
IF f_Y > 12 THEN f_Y = 12.
IF f_Y < 1  THEN f_Y = 1.
IF f_X < 1  THEN f_X = 1.
IF f_X > 80 - MF_WIDTH THEN f_X = 80 - MF_WIDTH.
MF_LEFT = f_X.
MF_TOP  = f_Y.
local   = true.
DEF VAR f_AUTOOPEN  AS CHAR NO-UNDO.
DEF VAR e_AUTOOPEN  AS CHAR NO-UNDO.
DEF VAR f_DELIMITER AS CHAR NO-UNDO.
DEF VAR f_FILEMASK  AS CHAR NO-UNDO.
DEF VAR f_CodePage  AS CHAR NO-UNDO.
f_Name      = TRIM(ENTRY(1, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_AUTOOPEN  = TRIM(ENTRY(2, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_DELIMITER = TRIM(ENTRY(3, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_FILEMASK  = TRIM(ENTRY(4, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_CodePage  = TRIM(ENTRY(5, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_EnPrint   = TRIM(ENTRY(6, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_DisDelete = TRIM(ENTRY(7, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_logstr    = TRIM(ENTRY(8, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_newlogstr = TRIM(ENTRY(9, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
f_ParamList = TRIM(ENTRY(10, f_Param, cuni:UNICAT_DELIMITER)) NO-ERROR.
DEF VAR f_Ext AS CHAR NO-UNDO.
DEF VAR iMode AS INT64 NO-UNDO.
/* Opredeljajem tip programmy otkrytija po rasshireniju faila */
f_Ext = TRIM(cprf:cfso:GetFileExt(f_FileName)).
IF f_Ext = "" THEN f_Ext = "TXT".
IF f_Name = "" THEN
 DO:
    IF      f_Ext = "txt"  THEN f_Name = "E".
    ELSE IF f_Ext = "tmp"  THEN f_Name = "E".
    ELSE IF f_Ext = "prn"  THEN f_Name = "P".
    ELSE IF f_Ext = "log"  THEN f_Name = "E".
    ELSE IF f_Ext = "csv"  THEN f_Name = "X".
    ELSE IF f_Ext = "doc"  THEN f_Name = "W".
    ELSE IF f_Ext = "ods"  OR f_Ext = "odf" OR f_Ext = "odt" THEN 
     DO: f_Name = "O". f_CodePage = "-1". END.
    ELSE IF f_Ext = "htm" OR f_Ext = "html" THEN 
     DO: 
        f_Name = "L". 
        Txt_Viewer = "lynx". 
     END.
    ELSE IF f_Ext = "xml"  THEN f_Name = "L".
    ELSE IF f_Ext = "vbs"  THEN f_Name = "L".
    ELSE IF f_Ext = "xls"  OR f_Ext = "pdf" OR f_Ext = "gz" OR f_Ext = "zip" THEN 
     DO: f_Name = "L". f_CodePage = "-1". END.
 END.
IF f_ParamList <> "" THEN DO:
    IF LOOKUP('LASER', f_ParamList, ':') > 0 THEN f_Laser = "LASER ".
END.
DEF VAR DOC_TYPE AS CHAR NO-UNDO.
/* Avto blokirovka preobrazovatelej codov dlja gruppy failov */
IF INDEX("ods;odf;xls;pdf;gz;zip;gif;bmp;jpg;jpeg", f_Ext) > 0 THEN f_CodePage = "-1".
/* */
IF      INDEX("txt;prn;csv;tmp;log;dat;", f_Ext) > 0  THEN DOC_TYPE = "TX".  /* TEXT     */
ELSE IF INDEX("htm;html;", f_Ext) > 0                 THEN DOC_TYPE = "HT".  /* HTML     */
ELSE IF INDEX("ods;odf;xls;odt;", f_Ext) > 0          THEN DOC_TYPE = "OO".  /* O.Office */
ELSE IF INDEX("gif;bmp;jpg;jpeg;png;", f_Ext) > 0     THEN DOC_TYPE = "PC".  /* Pictures */
ELSE IF INDEX("pdf;gz;zip;", f_Ext) > 0               THEN DOC_TYPE = "OT".  /* Other    */
ELSE DOC_TYPE = "TX".  /* TEXT     */
DEFINE TEMP-TABLE TmpExt NO-UNDO
    FIELD ID        AS INT64
    FIELD MENU_PREF AS CHAR
    FIELD MENU_NAME AS CHAR
    FIELD MENU_CHG  AS INT64
    
    INDEX PK ID
    INDEX Id Id.
DEFINE QUERY qTmp FOR TmpExt.
DEFINE BROWSE bTmp QUERY qTmp DISPLAY
    TmpExt.MENU_PREF FORMAT "X"
    TmpExt.MENU_NAME FORMAT "X(30)"
    WITH 16 DOWN
    SIZE 34 BY 10 NO-BOX NO-LABELS.
DEFINE FRAME Mf
    bTmp HELP "ENTER-Izvads; F4-Izeja; F3-LASER/MATRIX; "
    WITH SIZE 37 BY 12 TITLE "  Parametru Vё╫ana  " OVERLAY
    COL MF_LEFT ROW MF_TOP NO-LABELS.
DEFINE FRAME MfSh
WITH SIZE 37 BY 12 COL (MF_LEFT + 2) ROW (MF_TOP + 1)
 DCOLOR (1) PFCOLOR (1) /*OVERLAY*/ NO-BOX NO-LABELS.
    DEF VAR TmpFileName  AS CHAR  NO-UNDO INIT "din.tmp".
    DEF VAR Err          AS INT64 NO-UNDO.
    DEF VAR CopyFileName AS CHAR  NO-UNDO.    
    DEF VAR f_Transport  AS CHAR  NO-UNDO.
    DEF VAR e_MailTo    AS CHAR   NO-UNDO.
    DEF VAR e_Subject   AS CHAR   NO-UNDO.
    DEF VAR e_FileName  AS CHAR   NO-UNDO INIT "".
    DEF VAR e_CodePage  AS CHAR   NO-UNDO INIT "".
    DEF VAR e_Protokol  AS CHAR   NO-UNDO INIT "".
    DEF VAR e_Delimiter AS CHAR   NO-UNDO.
    
/*For security log get info*/
DEF VAR g_cStoredFileInfo_v AS CHAR NO-UNDO INITIAL "". 
/*Procedura logirovanija fajlov dlja bezopasnosti*/
FUNCTION SecurityInfoLogSave LOGICAL(cFile_v AS CHAR, cExportType_v AS CHAR):
    
    /*initial parameters*/
    DEF VAR bReturn_v      AS LOGICAL  NO-UNDO INITIAL NO.
    DEF VAR cSecurityDir_v AS CHAR     NO-UNDO INIT "/bank1/rep/user_reports/". /*ishodjaschaja papka*/
    DEF VAR cLogFile_v     AS CHAR     NO-UNDO INIT "". /*imja fajla loga*/
    DEF VAR dtmTimeStamp_v AS DATETIME NO-UNDO INITIAL NOW.
    
    /*defines*/
    DEF VAR cInputPath_v         AS CHAR NO-UNDO INITIAL "".
    DEF VAR cInputFileName_v     AS CHAR NO-UNDO INITIAL "".
    DEF VAR cFullInputFileName_v AS CHAR NO-UNDO INITIAL "".
    DEF VAR cOutputFileName_v    AS CHAR NO-UNDO INITIAL "".
    DEF VAR cTimeStampPrefix_v   AS CHAR NO-UNDO INITIAL "".
    DEF VAR cUser_v              AS CHAR NO-UNDO INITIAL "".
    DEF VAR cWorkstation_v       AS CHAR NO-UNDO INITIAL "".
    DEF VAR cMenuId_v            AS CHAR NO-UNDO INITIAL "".
    DEF VAR dFileSize_v          AS DECIMAL NO-UNDO.
    DEF VAR cYearDir_v           AS CHAR NO-UNDO INITIAL "".
    DEF VAR cMonthDir_v          AS CHAR NO-UNDO INITIAL "".
    DEF VAR cZipFile_v           AS CHAR NO-UNDO INITIAL "".
    DEF VAR bSaveCopy_v          AS LOGICAL NO-UNDO INITIAL NO.
    
    /*MAIN LOGIC*/
    /*get user id for log*/
    cUser_v        = cbnk:g-ofc.
    cWorkstation_v = cprf:cfso:GetHostName().
    cMenuId_v      = g-fname.
    
    /*process input file*/    
    cInputPath_v = cprf:cfso:GetFilePath(cFile_v).
    IF cInputPath_v EQ "" THEN DO:
        cInputPath_v = "./".
        cFullInputFileName_v = cInputPath_v + cFile_v.
    END.
    ELSE cFullInputFileName_v = cFile_v.
        
    cInputFileName_v     = cprf:cfso:GetFullFileName(cFullInputFileName_v).
    dFileSize_v          = cprf:cfso:Sys_Get_File_Size(cFullInputFileName_v).
    
    /*processing output files and dirs names*/
    cTimeStampPrefix_v = cprf:cstr:CFormat(dtmTimeStamp_v, "yyyymmdd_hhmmss.")
                       + STRING( MTIME(dtmTimeStamp_v) MODULO 1000, "999").
    cOutputFileName_v  = cTimeStampPrefix_v + "_" + cUser_v + "_" 
                       + cbnk:get_menu_loc(cMenuId_v) + "." + cprf:cfso:GetFileExt(cFullInputFileName_v).
    cYearDir_v         = cSecurityDir_v + cprf:cstr:CFormat(dtmTimeStamp_v, "yyyy/").
    cMonthDir_v        = cYearDir_v     + cprf:cstr:CFormat(dtmTimeStamp_v, "mm/").
    cLogFile_v         = cYearDir_v     + "reports_" + cprf:cstr:CFormat(dtmTimeStamp_v, "yyyymm") + ".log".
    
    /* Create folders log dir if not exist + permissions*/
    cprf:cfso:CreateDir(cSecurityDir_v). /* */
    cprf:cfso:CreateDir(cYearDir_v).     /* year subdir  */ 
    cprf:cfso:CreateDir(cMonthDir_v).    /* month subdir */
    
    /*create log file if not exist + permissions*/
    cprf:cfso:CreateFile(cLogFile_v).
    
    /*SECURITY LOG PART*/
    IF g_cStoredFileInfo_v EQ "" THEN DO:
        g_cStoredFileInfo_v = STRING(dFileSize_v) + "|" + cOutputFileName_v.
        bSaveCopy_v = YES.
    END.
    ELSE bReturn_v = YES.
    
    /*create record in log file*/
    OUTPUT TO VALUE(cLogFile_v) APPEND.
        PUT UNFORMATTED 
                        cTimeStampPrefix_v "|"
                        cUser_v "|"
                        cWorkstation_v "|"
                        cprf:cfso:HostName() "|"
                        cMenuId_v "|"
                        cbnk:get_menu_loc(cMenuId_v) "|"
                        cprf:cstr:KOI8_TO_ENG(TRIM(cExportType_v)) "|"
                        g_cStoredFileInfo_v
                        SKIP
                        . /*end put*/
    OUTPUT CLOSE.
    
    /*create copy of original file*/
    IF NOT bSaveCopy_v THEN RETURN bReturn_v.
    
    cOutputFileName_v = cInputPath_v + cOutputFileName_v.
    IF cprf:cfso:Sys_Copy_File(cFullInputFileName_v, cOutputFileName_v) EQ 0 THEN DO:
        cZipFile_v = cMonthDir_v + cprf:cfso:GetFullFileName(cOutputFileName_v + ".zip").
        
        /*create zip file*/
        cZipFile_v = cprf:cfso:Zip(cOutputFileName_v, cZipFile_v, 1).
        IF cprf:cfso:DirFileExists(cZipFile_v) THEN DO:
            cprf:cfso:Sys_Execute_Cmd("chmod 444 " + cZipFile_v).
            bReturn_v = YES.
        END.
    END.
    
    RETURN bReturn_v.
END FUNCTION. /*SecurityInfoLogSave*/
/*
/* ==============SECURITY_LOG_START============= */
IF cprf:cfso:FindFile(INPUT-OUTPUT f_FileName) = 0 THEN DO:
    IF NOT SecurityInfoLogSave(f_FileName, "FILE_CREATED") THEN MESSAGE "WARNING. Security processing error!" VIEW-AS ALERT-BOX.
END.
/* ==============SECURITY_LOG_END=============== */
*/
PROCEDURE PROCESS_CMD:
    DEF INPUT PARAMETER ReportTxt  AS CHAR.
    DEF INPUT PARAMETER f_Id       AS INT64.
    DEF INPUT PARAMETER f_Title    AS CHAR.
    if f_logstr <> "" then cbnk:log_wrt(1, f_logstr + f_Title + ";", '', '', '','').
    if f_newlogstr <> "" then cbnk:s_lginfo(f_newlogstr + ";" + f_Title).
        /*run log_wrt(1,f_logstr + f_Title + ";"). */
    pause 0 before-hide.
    
    /*Create log info for security reasons*/
    IF NOT SecurityInfoLogSave(ReportTxt, f_Title) THEN MESSAGE "WARNING. Security logging error!" VIEW-AS ALERT-BOX.
    
    f_Title         = " Izvades parametri (" + f_Title + ") ".
    TmpFileName     = "./rep_yyyymmdd_hhmmss." + f_Ext.
    Err             = 0.
    Txt_Viewer      = "".
    CopyFileName    = "".
    f_Transport     = "".
    e_MailTo        = "".
    e_Subject       = "".
    e_FileName      = "".
    e_CodePage      = "".
    e_Protokol      = "".
    e_Delimiter     = ";".
    DEF VAR f_Parent AS CHAR NO-UNDO.
    DEF VAR f_Doc    AS CHAR NO-UNDO INIT "PRINT_TXT".
    DEF VAR f_User   AS CHAR NO-UNDO.
    DEF VAR f_Tmp    AS CHAR NO-UNDO.
    f_User   = USERID(LDBNAME(1)).
    f_Tmp    = STRING(f_Id).
    f_Parent = cuni:UNICAT_USER_PARAM_ID(f_User, f_Doc, STRING(f_Id), "").
    DEF VAR e_PRIT      AS CHAR NO-UNDO.
    DEF VAR e_EKSPRINT  AS CHAR NO-UNDO.
    DEF VAR e_AUTOPRINT AS CHAR NO-UNDO.
    e_AUTOOPEN = "".
    DEF VAR e_SRV_IP    AS CHAR NO-UNDO.
    DEF VAR e_PRINTER   AS CHAR NO-UNDO.
    DEF VAR e_MAIL_SUBJ AS CHAR NO-UNDO.
    DEF VAR e_MAIL_TO   AS CHAR NO-UNDO.
    /* Zagruzhajem parametry */
    IF ReportTxt = "" THEN LEAVE.
    /*
     sys_detect_localtemp().                    /* Ustanavlivajem LocalTemp */
    */
    
    e_PRIT     = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "PROTOKOL", "").
    e_EKSPRINT = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "SPROTOKOL", "").
    e_CodePage = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "CONVERT", "").
    e_Protokol = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "PROTOKOL", "").
    e_FileName = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "FILENAME", "").
    Txt_Viewer = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "EDITOR", "").
    e_AUTOPRINT= cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "AUTOPRINT", "").
    e_AUTOOPEN = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "AUTOOPEN", "").
    e_DELIMITER= cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "DELIMITER", "").
    e_SRV_IP   = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "SRV_IP", "").
    e_PRINTER  = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "SRV_PRINTER","").
    e_MAIL_TO  = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "MAIL_TO","").
    e_MAIL_SUBJ= cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "MAIL_SUBJECT","").
    e_MAIL_SUBJ= Replace(e_MAIL_SUBJ, "%FileName%", ReportTxt).
    f_Transport= e_Protokol.
    e_Subject  = e_MAIL_SUBJ.
    IF f_CodePage  <> "" THEN e_CodePage = f_CodePage. /* Zhestkoje perekrytie konvertacii */
    IF f_DELIMITER <> "" THEN e_DELIMITER = f_DELIMITER.
    IF e_DELIMITER = "v" THEN e_DELIMITER = "|".
    IF f_AUTOOPEN  <> "" THEN e_AUTOOPEN  = f_AUTOOPEN. /* NODIALOG */
    Txt_Viewer = cuni:UNICAT_USER_PARAM(f_User, f_Doc, f_Tmp, "", "EDITOR", "").
    IF Txt_Viewer = "" THEN
     DO:
        Txt_Viewer = csys:Get_SysC_Chr("VIEWER", "").
        IF Txt_Viewer = "" THEN
            Txt_Viewer = csys:Get_SysC_Chr("EDITOR", "").
            IF Txt_Viewer = "" THEN Txt_Viewer = "$EDITOR".
     END.
    /* Формируем имя и путь промежуточного файла */
    IF e_FileName = "" THEN
        e_FileName = "" + cprf:cfso:GetFullFileName(ReportTxt).
    e_FileName   = Replace(e_FileName, "%FileName%", 
                   cprf:cfso:GetFullFileName(ReportTxt)).
    e_FileName   = Replace(e_FileName, "%TmpFileName%",
                   "rep_" + cprf:cstr:CFormat(today, time, "yyyymmdd_hhmmss")
                 + "." + cprf:cfso:GetFileExt(ReportTxt)).
    e_FileName   = Replace(e_FileName, "%TmpDocName%",
                   "rep_" + cprf:cstr:CFormat(today, time, "yyyymmdd_hhmmss")
                 + ".doc").
    e_FileName   = Replace(e_FileName, "%TmpCsvName%",
                   "rep_" + cprf:cstr:CFormat(today, time, "yyyymmdd_hhmmss")
                 + ".csv").
    e_FileName   = Replace(e_FileName, "%LocTmpPath%", cprf:cfso:LocalTemp).
    If f_FILEMASK <> "" THEN
     DO:
        /* f_FILEMASK - это вручную заданная маска файла через параметры */
        /* Убираем из маски путь к файлу, если он задан, но только,      */
        /* если этот путь не виндовый                                    */
        IF f_Id <> 30 AND index(f_FILEMASK, ":") < 1 
          AND (INDEX(f_FILEMASK, "/") > 0 OR INDEX(f_FILEMASK, "\\") > 0)
          THEN
         DO:
            f_FILEMASK = cprf:cfso:GetFullFileName(f_FILEMASK).
         END.
        IF (INDEX(f_FILEMASK, "/") <= 0 AND INDEX(f_FILEMASK, "\\") <= 0 ) 
           OR INDEX(f_FILEMASK, "%") <= 0 THEN
            e_FileName = cprf:cfso:GetFilePath(e_FileName) 
                       + cprf:cstr:CFormat(today, time, f_FILEMASK).
        ELSE
            e_FileName = cprf:cstr:CFormat(today, time, f_FILEMASK).
     END.
    TmpFileName  = cprf:cstr:CFormat(today, time, TmpFileName).
    
    /* Для всех виндовых выводов, где файл перекачивается на ПК,
       добавляем путь временного каталога хранения файлов, если не задан */
    If INDEX(e_FileName, '/') = 0 AND INDEX(e_FileName, '\\') = 0 AND
       (f_Id = 50 OR f_Id = 60 OR f_Id = 70 OR f_Id = 90 OR f_Id = 100) THEN
        e_FileName = cprf:cfso:LocalTemp + e_FileName.
    e_MailTo     = e_FileName.   
    CopyFileName = e_FileName.
    /* Отрабатываем разные выводы документов */
    IF f_Id = 10 THEN /* Ekr√ns */
     DO:
        IF DOC_TYPE = "OT" OR DOC_TYPE = "PC" OR DOC_TYPE = "OO" THEN
         DO:    
            cprf:cfso:Sys_Transfer(ReportTxt, cprf:cfso:LocalTemp 
                + CopyFileName, "TELNET").
            cprf:cfso:Sys_Remote_Start(cprf:cfso:LocalTemp + CopyFileName).
         END.
        ELSE
         DO:
            IF DOC_TYPE = "HT" THEN Txt_Viewer = 'mcview'.
            IF DOC_TYPE <> "TX" OR f_EXISTTHCV = ? THEN
                Cmd = "cp -f " + ReportTxt + " " + TmpFileName.
            ELSE
                Cmd = "thcv " + ReportTxt + " " + TmpFileName + " -t".
            cprf:cfso:Sys_Execute_Cmd(Cmd).
            Cmd = Txt_Viewer + " " + TmpFileName.
            cprf:cfso:Sys_Execute_Cmd(Cmd).
            cprf:cfso:Sys_Delete_File(TmpFileName).
            cprf:cfso:Sys_Clear().
         END.
     END.
    ELSE IF f_Id = 20 THEN /* Printeris */
     DO:
       IF DOC_TYPE = "HT" OR DOC_TYPE = "PC" THEN
        DO: /* HTML / PICTURES */
            IF DOC_TYPE = "PC" THEN /* PICTURES */
                cprf:win_htmlprint(ReportTxt, "", "TELNET", 1, "-1").
            ELSE /* TEXT/HTML DOCUMENTS */
             do:
                cprf:win_htmlprint(ReportTxt, "", "TELNET", 1, "0").
             end.
        END.
       ELSE IF DOC_TYPE = "OO" THEN
        DO: /* OPEN OFFICE DOCUMENTS */
            cprf:win_write(ReportTxt, "-p").
        END.
       ELSE /*IF DOC_TYPE = "TX" THEN OSTALJNYJE DOKUMENTY */ 
        DO:
            IF f_Laser <> "" THEN
             DO:
                IF f_EXISTTHCV = ? THEN
                 DO:
                   cprf:win_htmlprint(ReportTxt, "", "TELNET", 1, "0").
                 END.
                ELSE
                 DO:
                   Cmd = "thcv " + ReportTxt + " " + ReportTxt + ".htm -nocv".
                   cprf:cfso:Sys_Execute_Cmd(Cmd).
                   cprf:win_htmlprint(ReportTxt + ".htm", "", "TELNET", 1, "0").
                   cprf:cfso:Sys_Delete_File(ReportTxt + ".htm").
                 END.
             END.
            ELSE IF local THEN
             DO:
              IF f_Transport = "prit" THEN
               DO:
                    Cmd = "prit " + ReportTxt.
                    cprf:cfso:Sys_Execute_Cmd(Cmd).
               END.
              ELSE
                RUN PROCESS_R_FILE(ReportTxt, f_Id, f_Title).            
            END.
           ELSE
            DO:
              Cmd = "eksprint 1 < " + ReportTxt.
              cprf:cfso:Sys_Execute_Cmd(Cmd).
            END.
        END.
                
     END.
    ELSE IF f_Id = 30 THEN /* Fails */
     DO:
        if local then 
         do:
            /*
            e_CodePage = "-1".
            e_MailTo = "report.txt".
            f_Transport = "COPY".
            */
            RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
         end.
        else 
            run prn_fax.r(ReportTxt).
     END.
    ELSE IF f_Id = 40 THEN   /* DOS Fails */
     DO:
        /*e_CodePage = "2".*/
        RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
     END.
    ELSE IF f_Id = 50 THEN   /* UNICODE Fails */
     DO:
        /*e_CodePage = "0".*/
        RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
     END.
    ELSE IF f_Id = 60 THEN   /* EXCEL  */
     DO:
        e_Delimiter = cprf:win_excel_getdlm(ReportTxt, e_Delimiter).
        IF e_AUTOOPEN <> "AUTOOPEN" AND e_AUTOOPEN <> "NODIALOG" THEN
            run email_form_x.p( f_Title,
                            INPUT-OUTPUT e_MailTo,
                            INPUT-OUTPUT e_Subject,
                            INPUT-OUTPUT e_FileName,
                            INPUT-OUTPUT e_CodePage, 
                            INPUT-OUTPUT f_Transport,
                            INPUT-OUTPUT e_Delimiter,
                            ReportTxt).    
        RUN PROCESS_R_FILE(ReportTxt, f_Id, f_Title).
        IF CopyFileName = "" THEN LEAVE.
        Err = cprf:win_excel(TmpFileName, CopyFileName, e_Delimiter, f_Transport, "-1").
     END.
    ELSE IF f_Id = 70 THEN   /* WORD  */
     DO:
        RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
        IF CopyFileName = "" THEN LEAVE.
        Err = cprf:win_word(TmpFileName, CopyFileName, "p", f_Transport, "-1").
     END.
    ELSE IF f_Id = 80 THEN   /* EMAIL  */
     DO:
        DEF VAR f_to   AS CHAR NO-UNDO.
        DEF VAR f_Subj AS CHAR NO-UNDO.
        DEF VAR f_Msg  AS CHAR NO-UNDO.
        DEF VAR f_ThCv AS CHAR NO-UNDO.
        
        f_Subj = e_MAIL_SUBJ.
        IF e_MAIL_TO <> "" THEN
            f_To = e_MAIL_TO.
        ELSE
            f_to = USERID(LDBNAME(1)) + "@norvik.eu".
       IF DOC_TYPE = "TX" THEN e_CodePage = "0".
       
       IF e_AUTOOPEN <> "AUTOOPEN" AND e_AUTOOPEN <> "NODIALOG" THEN
            RUN email_form_g.p(INPUT-OUTPUT f_to,
                               INPUT-OUTPUT f_Subj,
                               INPUT-OUTPUT ReportTxt,
                               INPUT-OUTPUT e_CodePage,
                               INPUT-OUTPUT f_Msg,
                               INPUT-OUTPUT f_ThCv).
       IF cprf:cfso:FindFile(INPUT-OUTPUT ReportTxt) <> 0 THEN
        DO:
            IF e_AUTOOPEN <> "AUTOOPEN" AND e_AUTOOPEN <> "NODIALOG" THEN
             DO: MESSAGE "Fails [" ReportTxt "] neeksistё!". pause 3. END.
            ReportTxt = "".
        END.
       ELSE
           RUN PROCESS_FILE(ReportTxt, f_Id, f_Title). 
       cprf:e_mail(f_Msg, TmpFileName, f_to, f_Subj, 3, "-1", e_FileName).
     END.
    ELSE IF f_Id = 90 THEN   /* EXPLORER  */
     DO:
        RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
        IF CopyFileName = "" THEN LEAVE.
        
        Err = cprf:win_prg(TmpFileName, CopyFileName, "p", f_Transport, "-1").
     END.
    ELSE IF f_Id = 100 THEN   /* SWRITER  */
     DO:
        RUN PROCESS_FILE(ReportTxt, f_Id, f_Title).
        IF CopyFileName = "" THEN LEAVE.
        Err = cprf:win_write(TmpFileName, CopyFileName, "p", f_Transport, "-1").
     END.
                                                              
     cprf:cfso:Sys_Delete_File(TmpFileName).
    
    
    
    IF e_AUTOOPEN <> "AUTOOPEN" AND SEARCH(TmpFileName) <> ? THEN
     DO:    
         IF f_Id = 80 THEN
            MESSAGE "Atskaite ir nos╜t╗ta!". pause 3 no-message. 
            /*view-as alert-box.*/ /*pause 3 no-message.*/
         IF (f_Id = 90 OR f_Id = 70 OR f_Id = 60 OR f_Id = 100) THEN
            MESSAGE "Atskaite tiks atverta! Uzgaidiet...". pause 3 no-message. 
             /*view-as alert-box.*/ /*pause 5 no-message.*/
         IF (f_Id = 30 OR f_Id = 40 OR f_Id = 50) THEN
            MESSAGE "Atskaite ir saglab√ta! Datne " CopyFileName.
            pause 2 no-message.
     END.
    
     pause before-hide.
END.
PROCEDURE PROCESS_FILE:
        DEF INPUT PARAMETER ReportTxt  AS CHAR.
        DEF INPUT PARAMETER f_Id       AS INT64.
        DEF INPUT PARAMETER f_Title    AS CHAR.
        /*IF cprf:cfso:FindFile(INPUT-OUTPUT ReportTxt)  0 THEN RETURN.*/
        
        IF e_AUTOOPEN <> "AUTOOPEN" AND e_AUTOOPEN <> "NODIALOG" 
           AND f_Id ne 80 THEN
            run email_form_f.p( f_Title,
                            INPUT-OUTPUT e_MailTo,
                            INPUT-OUTPUT e_Subject,
                            INPUT-OUTPUT e_FileName,
                            INPUT-OUTPUT e_CodePage, 
                            INPUT-OUTPUT f_Transport,
                            ReportTxt).               
        
        RUN PROCESS_R_FILE(ReportTxt, f_Id, f_Title).
END.
PROCEDURE PROCESS_R_FILE:
    DEF INPUT PARAMETER ReportTxt  AS CHAR.
    DEF INPUT PARAMETER f_Id       AS INT64.
    DEF INPUT PARAMETER f_Title    AS CHAR.
    
    DEF VAR c_user AS CHAR.
    DEF VAR d_file AS CHAR.
    DEF VAR i AS INTEGER.
    CopyFileName = e_MailTo.
    IF e_MailTo = "" THEN LEAVE.
    f_Transport = cprf:cfso:Sys_Get_Auto_Transport(f_Transport, CopyFileName).
    /*MESSAGE e_CodePage f_Transport CopyFileName VIEW-AS ALERT-BOX.*/
    DEF VAR Cmd         AS CHAR NO-UNDO.
    DEF VAR r_ReportTxt AS CHAR NO-UNDO.
    r_ReportTxt = ReportTxt.
    IF f_EXISTTHCV <> ? AND f_Id > 40 AND DOC_TYPE = "TX" THEN
     DO:
        r_ReportTxt = cprf:cfso:GetFullFileName(ReportTxt) + ".t".
        /* Udaljajem ESC-posledovateljnosti iz faila */
        
        IF f_Id = 90 THEN /* v HTML */
         DO:
             Cmd = "thcv " + ReportTxt + " " + r_ReportTxt + " -h -nocv".
             CopyFileName = CopyFileName + ".htm".
             cprf:cfso:Sys_Execute_Cmd(Cmd).
         END.
        ELSE /* v TEXT FILE */
         DO:
            Cmd = "thcv " + ReportTxt + " " + r_ReportTxt + " -t -nocv".
            cprf:cfso:Sys_Execute_Cmd(Cmd).
         END.
     END.
    IF e_CodePage <> "-1" AND e_CodePage <> "" THEN
     DO:
       cprf:cfso:Sys_CP_Convert_File(r_ReportTxt, TmpFileName, e_CodePage).
     END.
    ELSE
     DO:
       cprf:cfso:Sys_Transfer(r_ReportTxt,TmpFileName,"COPY","","","","").
     END.
    
    IF r_ReportTxt <> ReportTxt THEN 
       cprf:cfso:Sys_Delete_File(r_ReportTxt).
        
    IF f_Transport = "EMAILF" THEN
     DO:
        CopyFileName = TmpFileName.
        TmpFileName  = "".
        IF e_Subject = "" THEN e_Subject = "PLATON".
     END.
    ELSE
     DO:
        e_MailTo = "".
        CopyFileName = Replace(CopyFileName, "\\", "/").
     END.
     
     IF f_Id <> 60 AND f_Id <> 70 AND f_Id <> 90 AND f_Id <> 100 
       AND f_Id <> 80 THEN 
     /* Iskljuchajem Excel, Word, MAIL, Explorer, OO */
      DO:
         cprf:cfso:Sys_Transfer(TmpFileName, CopyFileName, f_Transport, 
                                "", "", e_Subject, e_MailTo).
         if f_ID = 30 and f_Transport = "COPY" then do:
           /* opredeljajem nalicheje direktorii v shared-papke */
           c_user = "".
           repeat i = 1 to num-dbs:
             c_user = userid(ldbname(i)).
             if c_user <> "" then leave.
           end.
           if c_user <> "" then do:
             file-info:file-name = "/bank1/usershare/" + c_user.
             if file-info:full-pathname = ? then do:
               cprf:cfso:Sys_Execute_Cmd("mkdir " + "/bank1/usershare/" + c_user + " 2>/dev/null").
               cprf:cfso:Sys_Execute_Cmd("chmod -R 777 " + "/bank1/usershare/" + c_user + " 2>/dev/null").
               cprf:cfso:Sys_Execute_Cmd("date > " + "/bank1/usershare/" + c_user + "/.init 2>/dev/null").
             end.
             file-info:file-name = "/bank1/usershare/" + c_user.
             if file-info:full-pathname <> ? then do:
               d_file = CopyFileName.
               if r-index(d_file,"/") <> 0 then do:
                 d_file = substring(d_file,r-index(d_file,"/") + 1).
               end.
               d_file = "/bank1/usershare/" + c_user + "/" + d_file.
               cprf:cfso:Sys_Transfer(TmpFileName, d_file, f_Transport, 
                                      "", "", e_Subject, e_MailTo).
               cprf:cfso:Sys_Execute_Cmd("chmod 666 " + d_file + " 2>/dev/null").               
             end.
           end.
         end.
         cprf:cfso:Sys_Delete_File(TmpFileName).
      END.
END.
PROCEDURE Init_Mf:
    FRAME Mf:TITLE-DCOLOR   = 1.
    FRAME Mf:TITLE          = MF_TITL. /*" Anal╗zes tips ".*/
    FRAME Mf:DCOLOR         = 0.    
    FRAME Mf:WIDTH          = MF_WIDTH.
    FRAME MfSh:WIDTH        = MF_WIDTH.
    FRAME Mf:HEIGHT         = MF_HEIGHT.
    FRAME MfSh:HEIGHT       = MF_HEIGHT.
    bTmp:PFCOLOR = 2. /* WHITE/CYAN */
END.
FUNCTION RST_EDTLINE int64 (f_Id AS INT64, f_Pref AS CHAR, f_Des AS CHAR):
    IF f_EnPrint <> "" AND INDEX(f_EnPrint, f_Pref) = 0 THEN RETURN -1.
    FIND FIRST TmpExt WHERE TmpExt.Id = f_Id NO-ERROR.
    IF NOT AVAILABLE TmpExt THEN CREATE TmpExt.
    TmpExt.Id = f_Id.
    TmpExt.MENU_PREF = f_Pref.
    TmpExt.MENU_NAME = f_Des.
    RETURN 0.
END.
ON F7, PF7 OF bTmp
 DO:
    IF cbnk:g-ofc ne "ADM" THEN LEAVE. /* nelzja komu-popadja menajt nastrojki */
    IF NOT AVAILABLE TmpExt THEN LEAVE.
    DEF VAR f_Templ AS CHAR NO-UNDO.
    DEF VAR f_Doc   AS CHAR NO-UNDO.
    DEF VAR f_Fil   AS CHAR NO-UNDO.
    DEF VAR f_User  AS CHAR NO-UNDO INIT "ALL".
    f_Doc   = "PRINT_TXT".
    f_Templ = STRING(TmpExt.Id).
    t_Id   = TmpExt.Id.
    RUN DisableMf.
    RUN ofc_prn_set.p(INPUT-OUTPUT f_Templ, 
                      INPUT-OUTPUT f_Doc, 
                      INPUT-OUTPUT f_User,
                      INPUT-OUTPUT f_Fil).
    RUN ShowMf.
    RUN Reposition.
 END.
ON NEW-LINE OF bTmp
 DO:
    IF cbnk:g-ofc ne "ADM" THEN LEAVE. /* nelzja komu-popadja menajt nastrojki */
    IF NOT AVAILABLE TmpExt THEN LEAVE.
    DEF VAR f_Templ AS CHAR NO-UNDO.
    DEF VAR f_Doc   AS CHAR NO-UNDO.
    DEF VAR f_Fil   AS CHAR NO-UNDO.
    DEF VAR f_User  AS CHAR NO-UNDO INIT "".
    f_Doc   = "PRINT_TXT".
    f_Templ = STRING(TmpExt.Id).
    t_Id   = TmpExt.Id.
    f_User = USERID(LDBNAME(1)).
    RUN DisableMf.
    RUN ofc_prn_set.p(INPUT-OUTPUT f_Templ, 
                      INPUT-OUTPUT f_Doc, 
                      INPUT-OUTPUT f_User,
                      INPUT-OUTPUT f_Fil).
    RUN ShowMf.
    RUN Reposition.
 END.
ON ANY-PRINTABLE OF bTmp
 DO:  
    IF lastkey >= 32 THEN
      IF f_Name =  CHR(lastkey) THEN
          APPLY "RETURN" TO bTmp.
    f_Name = CHR(lastkey).
    RUN Reposition.
 END.
ON BACKSPACE OF bTmp
 DO:
    IF LENGTH(f_Name) > 0 THEN
     DO:
        f_Name = SUBSTRING(f_Name, 1, LENGTH(f_Name) - 1).
        RUN Reposition.
     END.
 END.
ON UP-ARROW,DOWN-ARROW, PAGE-UP, PAGE-DOWN OF bTmp
 DO:
    f_Name = "".
    local = true.
    HIDE MESSAGE.
    RUN ShowHelp.
 END.
ON VALUE-CHANGED OF bTmp
 DO:
    RUN ShowHelp.
 END.
 
ON RETURN OF bTmp
 DO:
    RUN ON_RETURN.
 END.
ON F2, PF2 OF bTmp
 DO:
    RUN DisableMf.
    RUN opics_help("HELP_PRN_PROC_E").
    RUN ShowMf. 
 END.
ON F3, PF3 OF bTmp
 DO:
    /***************************/
    /* SWITCH TO LASER PRINTER */
    /***************************/
    IF AVAILABLE TmpExt THEN t_Id = TmpExt.Id.
    IF f_Laser = "" THEN 
     DO: 
         f_Laser = "LASER ". 
         RST_EDTLINE(20, "P", "Printeris (Laser)"). 
     END. 
    ELSE
     DO: 
         f_Laser = "". 
         RST_EDTLINE(20, "P", "Printeris (Matrix)"). 
     END.
    RUN Rec_Open.
    RUN ShowMf. 
 END.
ON PREV-WORD OF bTmp   /* CTRL-P */
 DO:
    local = false.
    f_Name = "p".
    RUN Reposition.
 END.
ON ANY-KEY OF bTmp
 DO:
    IF keyfunction(lastkey) = "FIND" THEN
     DO:                /* CTRL-F */
        local = false.
        f_Name = "f".
        RUN Reposition.
     END.
 END.
 
 ON F4, PF4 OF bTmp
  DO:
    RUN HideMf.
    DELETE_OBJECTS().
  END.
 
FUNCTION RST_ADDLINE int64 (f_Id AS INT64, f_Pref AS CHAR, f_Des AS CHAR):
    IF f_EnPrint <> "" AND INDEX(f_EnPrint, f_Pref) = 0 THEN RETURN -1.
    CREATE TmpExt.
    TmpExt.Id = f_Id.
    TmpExt.MENU_PREF = f_Pref.
    TmpExt.MENU_NAME = f_Des.
    RETURN 0.
END.
PROCEDURE ON_RETURN:
    DEF VAR e_Id AS INT64 NO-UNDO.
    IF NOT AVAILABLE TmpExt THEN LEAVE.
    IF f_AUTOOPEN <> "AUTOOPEN" THEN RUN DisableMf.
    t_Id   = TmpExt.Id.
    IF cprf:cfso:FindFile(INPUT-OUTPUT f_FileName) = 0 THEN
        RUN Process_Cmd(f_FileName, t_Id, TmpExt.MENU_NAME).
    ELSE IF f_AUTOOPEN <> "AUTOOPEN" AND f_AUTOOPEN <> "NODIALOG" THEN
     DO:
        MESSAGE COLOR I "Fails: " + f_FileName + " - neeksistё!"
            SKIP "Izvads atcelts!"
            SKIP "P√rbaudiet faila nosaukumu vai veidojiet no jauna!"
            VIEW-AS ALERT-BOX.
     END.
    IF f_AUTOOPEN <> "AUTOOPEN" THEN
     DO:
        HIDE ALL NO-PAUSE.
        RUN ShowMf.
        RUN Reposition.
     END.
END.
PROCEDURE Recordset:
    DEF BUFFER bf_TmpExt FOR TmpExt.
    EMPTY TEMP-TABLE TmpExt.
    RST_ADDLINE(10, "E", "Ekr√ns").
    RST_ADDLINE(20, "P", "Printeris").
    RST_ADDLINE(30, "F", "Fails").
    RST_ADDLINE(40, "D", "DOS Fails").
    RST_ADDLINE(50, "U", "UNICODE Fails").
    RST_ADDLINE(60, "X", "Atvert ar EXCEL (WINDOWS)").
    RST_ADDLINE(70, "W", "Atvert ar WORD  (WINDOWS)").
    RST_ADDLINE(80, "M", "S╜t╗t  ar EMAIL (NORVIK)").
    RST_ADDLINE(90, "L", "Atvert ar windows explorer").
    RST_ADDLINE(100,"O", "Atvert ar OpenOffice     ").
    RUN Rec_Open.
END PROCEDURE.
PROCEDURE Rec_Open:
    OPEN QUERY qTmp FOR EACH TmpExt USE-INDEX PK.
    RUN Reposition.
END.
PROCEDURE Reposition:
    DEF BUFFER bfTmpTab FOR TmpExt.
    IF f_Name <> "" THEN
     DO:
        
        FIND FIRST bfTmpTab WHERE bfTmpTab.MENU_PREF BEGINS f_Name 
            USE-INDEX PK NO-LOCK NO-ERROR.
        IF NOT AVAILABLE bfTmpTab THEN
         DO:
            f_Name = SUBSTRING(f_Name, 1, LENGTH(f_Name) - 1).
            RUN Reposition.
            RETURN.
         END.
         PAUSE 0 BEFORE-HIDE.
         HIDE MESSAGE.
         IF f_AUTOOPEN <> "AUTOOPEN" THEN MESSAGE f_Name.
     END.
    ELSE
     DO:
        HIDE MESSAGE.
         FIND FIRST bfTmpTab WHERE bfTmpTab.Id   = t_Id 
                         USE-INDEX Id NO-LOCK NO-ERROR.
     END.
    IF NOT AVAILABLE bfTmpTab THEN
        FIND FIRST bfTmpTab WHERE bfTmpTab.Id >= t_Id 
        USE-INDEX Id NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bfTmpTab THEN 
        FIND LAST bfTmpTab WHERE bfTmpTab.Id  <= t_Id 
            USE-INDEX Id NO-LOCK NO-ERROR.
    
    IF f_AUTOOPEN <> "AUTOOPEN" THEN
     DO:
        IF AVAILABLE bfTmpTab THEN
         DO:
             bTmp:SET-REPOSITIONED-ROW(7, "CONDITIONAL") IN FRAME Mf.
             REPOSITION qTmp TO RECID recid(bfTmpTab) NO-ERROR.
         END.
     END.
    ELSE
     DO:
        FIND FIRST TmpExt WHERE recid(TmpExt) = recid(bfTmpTab) NO-ERROR.
     END.
END PROCEDURE.
PROCEDURE ShowMf:
    VIEW FRAME MfSh. PAUSE 0.
    VIEW FRAME Mf.   PAUSE 0.
    ENABLE ALL WITH FRAME Mf.
    RUN ShowHelp.
    
END PROCEDURE.
PROCEDURE ShowHelp:
    PUT SCREEN COLOR "" "ENTER-Izvads; F4-Izeja; F3-LASER/MATRIX;" COL 1 ROW 25.
    PUT SCREEN COLOR "YELLOW/BLUE" f_Laser COL FRAME MF:COL + 30 ROW FRAME MF:ROW.
END.
PROCEDURE HideMf:
    HIDE FRAME Mf.   PAUSE 0.
    HIDE FRAME MfSh. PAUSE 0.
END PROCEDURE.    
PROCEDURE DisableMf:
    DISABLE ALL WITH FRAME Mf. PAUSE 0.
END PROCEDURE.
IF f_AUTOOPEN <> "AUTOOPEN" THEN
 DO:
    RUN Init_Mf.
    RUN ShowMf.
 END.
RUN Recordset.
t_Id = 1. 
RUN Reposition. 
IF f_AUTOOPEN = "AUTOOPEN" THEN RUN ON_RETURN. 
HIDE MESSAGE NO-PAUSE.
IF f_AUTOOPEN <> "AUTOOPEN" THEN
 DO:    
    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4 OF FRAME Mf.
 END.
RUN HideMf.
DELETE_OBJECTS().
