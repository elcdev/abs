/*
**********************************
AUTH: ALEZHU
DATE: 20.09.2005
DES:  Export parametrers for excel
**********************************
*/
DEFINE INPUT        PARAMETER e_Title     AS CHAR.
DEFINE INPUT-OUTPUT PARAMETER e_MailTo    AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_Subject   AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_FileName  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_CodePage  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_Protokol  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_Delimiter AS CHAR NO-UNDO.
DEFINE INPUT        PARAMETER e_FileSrc  AS CHAR NO-UNDO.
{comdlg.f new}
DEF VAR cext AS sysext.
DEF VAR cstr as sysstr.
cext = new sysext().
cstr = new sysstr().
FUNCTION DELETE_OBJECTS INT64():
    DELETE OBJECT cext NO-ERROR.
    DELETE OBJECT cstr NO-ERROR.
END.
DEF VAR PosX AS DEC.
DEF VAR PosY AS DEC.
DEFINE BUTTON e_BtAttach   LABEL "Pievienots dokuments" .
DEFINE BUTTON e_BtCnv      LABEL "Unicode" .
DEFINE BUTTON e_BtProtokol LABEL "AUTO".
PosX = 5.
PosY = 10.
IF e_MailTo = "" THEN 
    e_MailTo = "c:/rep_" + cstr:CFormat(today, time, "yyyymmdd_hhmmss")
             + ".txt".
IF e_CodePage = "" THEN e_CodePage = "-1".
IF e_Protokol = "" THEN e_Protokol = "AUTO".
DEFINE FRAME Mf
SKIP(1)
"  Fails: " SKIP
"               (C:/atskaite.txt - DOS/WIN; ./atskaite.txt-UNIX) " SKIP
"  Sadal¨t–js:" SKIP
"  Dokuments: " SKIP
"  Konvert£t: " SKIP
"  Protokol:  " SKIP
e_MailTo     AT COL 16 ROW 2 HELP "F1-S­t¨t/Saglab–t/Turpin–t;F2-Browse;F4-Izeja;" FORMAT "X(50)"
e_Delimiter  AT COL 16 ROW 4 HELP "F1-S­t¨t/Saglab–t/Turpin–t;F4-Izeja;[_]=Space;[t]=Tab;" FORMAT "X"
e_BtAttach   AT COL 16 ROW 5 HELP "F1-S­t¨t/Saglab–t/Turpin–t;F4-Izeja;"
e_BtCnv      AT COL 16 ROW 6 HELP "F1-S­t¨t/Saglab–t/Turpin–t;F4-Izeja;"
e_BtProtokol AT COL 16 ROW 7 HELP "F1-S­t¨t/Saglab–t/Turpin–t;F4-Izeja;"
WITH SIZE 70 BY 9 TITLE " Faila eksporta parametri " OVERLAY
COL PosX ROW PosY NO-LABELS
.
FRAME Mf:TITLE-DCOLOR = 1.
e_MailTo:WIDTH  IN FRAME Mf = 50.
e_MailTo:FORMAT IN FRAME Mf = "X(1000)".
IF e_Title <> "" THEN FRAME Mf:TITLE = e_Title.
DEFINE FRAME MfSh
WITH SIZE 70 BY 9 COL (Posx + 2) ROW (PosY + 1)
 DCOLOR (1) PFCOLOR (1) OVERLAY NO-BOX NO-LABELS.
/*
--------------------------------------------------
/*** TRIGGERS ***/
--------------------------------------------------
*/
ON LEAVE OF e_MailTo  ASSIGN e_MailTo.
ON PF2, F2 OF e_MailTo
 DO:
    IF INDEX(e_MailTo, "@") = 0 THEN
     DO:
        DlgType = 1.
        RUN DisableMf.
        DlgFullFileName = e_MailTo.
        RUN fle_list.p. 
        IF DlgFullFileName <> "" THEN e_MailTo = DlgFullFileName.
        RUN ShowMf.
     END.
 END.
ON LEAVE OF e_Delimiter ASSIGN e_Delimiter = e_Delimiter:SCREEN-VALUE.
ON CHOOSE OF e_BtAttach
 DO:
    def var Cmd as char.
    cmd = "mcedit " + e_FileSrc.
    unix value(cmd). pause 0.
    RUN ShowMf.
 END.
ON CHOOSE OF e_BtCnv
 DO:
   DEF VAR f_Ext_Name AS CHAR.
   DEF VAR f_Cnv      AS INT64 .
   f_Ext_Name = "CP_CONVERSION". 
   f_Cnv = int64(e_CodePage).
   RUN DisableMf.
   RUN email_cp.p(30,
                   7, 
                   INPUT-OUTPUT f_Cnv, INPUT-OUTPUT f_Ext_Name,
                  " Code Page Conversion ").
   e_CodePage = STRING(f_Cnv).
   RUN ShowMf.
 END.
ON CHOOSE OF e_BtProtokol
 DO:
   DEF VAR f_Ext_Name AS CHAR.
   DEF VAR f_Cnv      AS INT64 .
   f_Ext_Name = "EXP_PROTOKOL". 
   RUN DisableMf.
   RUN email_cps.p(30,
                   7, 
                   INPUT-OUTPUT e_Protokol, INPUT-OUTPUT f_Ext_Name,
                  " Export Protokol ").
   RUN ShowMf.
 END.
ON PF1 OF FRAME Mf
 DO:
    ASSIGN e_MailTo /*e_Subject*/ e_Delimiter.
    IF e_Delimiter = "_" THEN e_Delimiter = " ".
    IF e_Delimiter = "t" THEN e_Delimiter = "\tab".
    IF e_MailTo = "" THEN 
     DO:
         MESSAGE "File name does not entered!" VIEW-AS ALERT-BOX.
         LEAVE.
     END.
     RUN HideMf.
     APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
     RETURN.
 END.
ON PF4 OF FRAME Mf 
 DO:
    e_MailTo = "".
    RUN HideMf.
    DELETE_OBJECTS().
 END.
/*
---------------------------------------------
MAIN BLOCK
---------------------------------------------
*/
RUN ShowMf.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW 
      OR PF4 OF FRAME Mf OR GO OF FRAME Mf
.
RUN HideMf.
DELETE_OBJECTS().
/*
---------------------------------------------
INTERNAL PROCEDURES
---------------------------------------------
*/
PROCEDURE ShowMf:
    VIEW FRAME MfSh. PAUSE 0.
    Disp e_MailTo /*e_Subject*/ e_Delimiter WITH FRAME Mf.
    VIEW FRAME Mf.   PAUSE 0.
    ENABLE ALL WITH FRAME Mf.
    e_BtCnv:LABEL IN FRAME Mf = cext:Gt(e_CodePage, "CP_CONVERSION",
    "Unknown").
    e_BtProtokol:LABEL IN FRAME Mf = cext:Gt(e_Protokol, "EXP_PROTOKOL",
    "Unknown").
END PROCEDURE.
PROCEDURE HideMf:
    HIDE FRAME Mf.   PAUSE 0.
    HIDE FRAME MfSh. PAUSE 0.
END PROCEDURE.
PROCEDURE DisableMf:
    DISABLE ALL WITH FRAME Mf.   PAUSE 0.
    DISABLE ALL WITH FRAME MfSh. PAUSE 0.
END PROCEDURE.