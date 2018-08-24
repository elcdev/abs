/*
**********************************
AUTH: ALEZHU
DATE: 20.09.2005
DES:  Export parameters for EMAIL
**********************************
*/
DEFINE INPUT-OUTPUT PARAMETER e_MailTo   AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_Subject  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_FileName AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER e_CodePage AS CHAR NO-UNDO.
DEF VAR cext AS sysext.
DEF VAR cfso AS sysfso.
DEF VAR cprf AS sysprf.
cext = new sysext().
cfso = new sysfso().
cprf = new sysprf().
FUNCTION DELETE_OBJECTS INT64():
    DELETE OBJECT cext NO-ERROR.
    DELETE OBJECT cfso NO-ERROR.
    DELETE OBJECT cprf NO-ERROR.
END.
DEF VAR PosX AS DEC NO-UNDO.
DEF VAR PosY AS DEC NO-UNDO.
DEFINE BUTTON e_BtAttach LABEL "Enter to view attached document" .
DEFINE BUTTON e_BtCnv    LABEL "Unicode" .
 PosX = 5.
 PosY = 8.
DEFINE FRAME Mf
SKIP(1)
"  Mail TO:   " SKIP
"  Subject:   " SKIP
"  Attachment:" SKIP
"  Conversion:" SKIP
e_MailTo   AT COL 16 ROW 2 HELP "F1-S負系 EMAIL;F4-Izeja;" FORMAT "X(50)"
e_Subject  AT COL 16 ROW 3 HELP "F1-S負系 EMAIL;F4-Izeja;" FORMAT "X(50)"
e_BtCnv    AT COL 16 ROW 5 HELP "F1-S負系 EMAIL;F4-Izeja;"
e_BtAttach AT COL 16 ROW 4 HELP "F1-S負系 EMAIL;F4-Izeja;" 
WITH SIZE 70 BY 8 TITLE "Enter E-MAIL information" OVERLAY
COL PosX ROW PosY NO-LABELS
.
FRAME Mf:TITLE-DCOLOR = 1.
DEFINE FRAME MfSh
WITH SIZE 70 BY 8 COL (Posx + 2) ROW (PosY + 1)
 DCOLOR (1) PFCOLOR (1) OVERLAY NO-BOX NO-LABELS.
/*
--------------------------------------------------
/*** TRIGGERS ***/
--------------------------------------------------
*/
ON LEAVE OF e_MailTo  ASSIGN e_MailTo.
ON LEAVE OF e_Subject ASSIGN e_Subject.
ON CHOOSE OF e_BtAttach
 DO:
    IF e_FileName = "" THEN LEAVE.
    cprf:EDITOR = "mcedit".
    cprf:unix_term(e_FileName).
    /*
    def var Cmd as char.
    cmd = "mcedit " + e_FileName.
    unix value(cmd). pause 0.
    */
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
   /*e_BtCnv:LABEL IN FRAME Mf = Get_Ext_ChrD(f_CodePage, f_Ext_Name, "Uncnown").*/
   e_CodePage = STRING(f_Cnv).
   RUN ShowMf.
 END.
ON PF1 OF FRAME Mf
 DO:
     ASSIGN e_MailTo e_Subject.
    IF e_MailTo = "" THEN 
     DO:
         MESSAGE "Mail To does not entered!" VIEW-AS ALERT-BOX.
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
    Disp e_MailTo e_Subject WITH FRAME Mf.
    VIEW FRAME Mf.   PAUSE 0.
    ENABLE ALL WITH FRAME Mf.
    e_BtCnv:LABEL IN FRAME Mf 
         = cext:Gt(e_CodePage, "CP_CONVERSION", "Unknown").
    IF e_FileName <> "" THEN
       e_BtAttach:LABEL IN FRAME Mf
             = SUBSTRING("File: " + cfso:GetFullFileName(e_FileName), 1, 30).
     ELSE
        e_BtAttach:LABEL IN FRAME Mf = "No attachement!".
END PROCEDURE.
PROCEDURE HideMf:
    HIDE FRAME Mf   . PAUSE 0.
    HIDE FRAME MfSh . PAUSE 0.
END PROCEDURE.
PROCEDURE DisableMf:
    DISABLE ALL WITH FRAME Mf.   PAUSE 0.
    DISABLE ALL WITH FRAME MfSh. PAUSE 0.
END PROCEDURE.
