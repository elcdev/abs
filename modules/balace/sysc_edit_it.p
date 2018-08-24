/*
******************************
AUTH: ALEZHU
DATE: 28.12.2004
DES:  SysC information editor
******************************
*/
DEFINE INPUT-OUTPUT PARAMETER f_SysC  AS CHAR.
DEFINE INPUT PARAMETER f_Mode AS INT64.
{sysc.f}
DEF VAR eSysC      AS CHAR FORMAT "X(20)".
DEF VAR eSysC_Old  AS CHAR.                  /* Old report kod */
DEF VAR eDes       AS CHAR FORMAT "X(40)".
DEF VAR eDaVal     AS DATE FORMAT "99.99.9999".
DEF VAR eDeVal     AS DEC  FORMAT ">>>>>>>>>>>>9.99".
DEF VAR eInVal     AS INT64  FORMAT ">>>>>>>>>9".
DEF VAR eLoVal     AS LOG  FORMAT "yes/no".
DEF VAR eChVal     AS CHAR FORMAT "X(20)".
DEF VAR f_Help     AS CHAR.
DEF BUFFER bf_SysC FOR Bank.SysC.
DEF VAR PosX AS DEC.
DEF VAR PosY AS DEC.
 f_Help = "[F1]-Save; [F4]-Exit.".
 eSysC_Old = f_SysC.
 PosX = 11.
 PosY = 8.
DEFINE FRAME Mf
SKIP(1)
"  SysC name       " SKIP
"  Description     " SKIP
"  Date value      " SKIP
"  Decimal value   " SKIP
"  Integer value   " SKIP
"  Logical value   " SKIP
"  Character value " SKIP
eSysC      AT COL 19 ROW 2 HELP " " 
eDes       AT COL 19 ROW 3 HELP " " 
eDaVal     AT COL 19 ROW 4 HELP " " 
eDeVal     AT COL 19 ROW 5 HELP " "
eInVal     AT COL 19 ROW 6 HELP " "
eLoVal     AT COL 19 ROW 7 HELP " "
eChVal     AT COL 19 ROW 8 HELP " "
WITH SIZE 62 BY 11 TITLE "SysC information editor" OVERLAY
COL PosX ROW PosY NO-LABELS
.
FRAME Mf:TITLE-DCOLOR = 1.
eSysC:HELP     IN FRAME Mf = f_Help.
eDaVal:HELP    IN FRAME Mf = f_Help.
eDeVal:HELP    IN FRAME Mf = f_Help.
eInVal:HELP    IN FRAME Mf = f_Help.
eLoVal:HELP    IN FRAME Mf = f_Help.
eChVal:HELP    IN FRAME Mf = f_Help.
eDes:HELP      IN FRAME Mf = f_Help.
eDes:WIDTH     IN FRAME Mf = 40.
eDes:FORMAT    IN FRAME Mf = "X(250)".
eChVal:WIDTH   IN FRAME Mf = 40.
eChVal:FORMAT  IN FRAME Mf = "X(250)".
DEFINE FRAME MfSh
WITH SIZE 62 BY 11 COL (Posx + 2) ROW (PosY + 1)
 DCOLOR (1) PFCOLOR (1) OVERLAY NO-BOX NO-LABELS.
/*
--------------------------------------------------
/*** TRIGGERS ***/
--------------------------------------------------
*/
ON LEAVE OF eSysC    ASSIGN eSysC.
ON LEAVE OF eDes     ASSIGN eDes.
ON LEAVE OF eDaVal   ASSIGN eDaVal.
ON GO OF FRAME Mf
 DO:
     ASSIGN eSysC eDes eDaVal eDeVal eInVal eLoVal eChVal.
     IF eSysC = "" THEN 
      DO:
         MESSAGE "ERROR! SysC name must be set!"
         VIEW-AS ALERT-BOX.
         LEAVE.
      END.
     IF f_SysC = "" THEN
      DO:
        FIND FIRST bf_SysC WHERE bf_SysC.SysC = eSysC NO-LOCK NO-ERROR.
        IF AVAILABLE bf_SysC THEN 
         DO:
             MESSAGE "SysC name " + eSysC + " already exist!" 
             VIEW-AS ALERT-BOX.
             LEAVE.
         END.
      END.
     RUN SaveItem.
     APPLY "WINDOW-CLOSE" TO CURRENT-WINDOW.
     RETURN.
 END.
ON PF4, F4 OF FRAME Mf RUN HideMf.
/*
---------------------------------------------
MAIN BLOCK
---------------------------------------------
*/
RUN RecordSet.
RUN ShowMf.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4 OF FRAME Mf.
RUN HideMf.
/*
---------------------------------------------
INTERNAL PROCEDURES
---------------------------------------------
*/
PROCEDURE SaveItem:
/*    MESSAGE "Saving" VIEW-AS ALERT-BOX.    */
    DEF VAR tmpParId AS INT64.
    DEF VAR tmpPrId  AS INT64.
    DEF VAR is_New   AS INT64.
    
    IF eSysC_Old <> "" THEN
     DO:
        Is_New = 0.
        FIND FIRST bf_SysC WHERE bf_SysC.SysC = eSysC_Old NO-ERROR.
        IF NOT AVAILABLE bf_SysC THEN
         DO:
             MESSAGE "Unknown SysC identifier! (" f_SysC ")" VIEW-AS ALERT-BOX.
             LEAVE.
         END.
     END.
    ELSE
     DO:
        Is_New = 1.
        CREATE bf_SysC.
     END.
        
    IF AVAILABLE bf_SysC THEN
      DO:
        bf_SysC.SysC    = eSysC.
        bf_SysC.Des     = eDes.
        bf_SysC.DaVal   = eDaVal.
        bf_SysC.DeVal   = eDeVal.
        bf_SysC.InVal   = eInVal.
        bf_SysC.ChVal   = eChVal.
        bf_SysC.LoVal   = eLoVal.
        f_SysC = eSysC.
      END.
END PROCEDURE.
PROCEDURE RecordSet:
    FIND bf_SysC WHERE bf_SysC.SysC = f_SysC NO-LOCK NO-ERROR.
    IF AVAILABLE bf_SysC THEN
     DO:
         eSysC   = bf_SysC.SysC.
         IF eSysC_Old = "" THEN eSysC_Old = eSysC.
         eDes    = bf_SysC.Des.
         eDaVal  = bf_SysC.DaVal.
         eDeVal  = bf_SysC.DeVal.
         eInVal  = bf_SysC.InVal.
         eLoVal  = bf_SysC.LoVal.
         eChVal  = bf_SysC.ChVal.
     END.
END PROCEDURE.
PROCEDURE ShowMf:
    VIEW FRAME MfSh. PAUSE 0.
    eSysC:WIDTH   IN FRAME Mf = 40.
    eSysC:PFCOLOR IN FRAME Mf = 007.
    eSysC:DCOLOR  IN FRAME Mf = 024.
    eSysC:FORMAT  IN FRAME Mf = "X(100)".
    eDes:WIDTH    IN FRAME Mf = 40.
    eDes:PFCOLOR  IN FRAME Mf = 6.
    eDes:FORMAT   IN FRAME Mf = "X(3000)".
    eChVal:WIDTH  IN FRAME Mf = 40.
    eChVal:FORMAT IN FRAME Mf = "X(3000)".
    eChVal:PFCOLOR  IN FRAME Mf = 10.
    VIEW FRAME Mf.   PAUSE 0.
    Disp eSysC eDes eDaVal eDeVal eInVal eLoVal eChVal
            WITH FRAME Mf.
    ENABLE ALL WITH FRAME Mf.
    IF f_Mode = 1 THEN
     DO:
        DISABLE eSysC eDes WITH FRAME Mf.
     END.
END PROCEDURE.
PROCEDURE HideMf:
    HIDE FRAME Mf.   PAUSE 0.
    HIDE FRAME MfSh. PAUSE 0.
    HIDE FRAME MfSh. PAUSE 0.
END PROCEDURE.
