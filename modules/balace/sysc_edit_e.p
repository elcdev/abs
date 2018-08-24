/*
  AUTH: ALEZHU
  DATE: 28.12.2004
  DESC: SysC editor V1.00 (BROWSER)
*/
DEF INPUT-OUTPUT PARAMETER f_SysC AS CHAR. /* REPOSITIONED REPORT KOD */
DEF INPUT PARAMETER        f_Mode AS INT64.  /* 0-general; 1-selector   */
{sysc.f}
DEFINE BUFFER bf_Sysc  FOR Bank.SysC.
DEF VAR PosY  AS DEC.
DEF VAR PosX  AS DEC.
DEF VAR f_Id AS INT64.
DEF VAR Rez   AS INT64.
DEF VAR answ  AS LOG.
DEF VAR fName AS CHAR.
DEF VAR e_Id AS INT64.
DEF VAR e_SysC AS CHAR.
PROCEDURE SecChange:
END PROCEDURE.
RUN SecChange.
PosY = 1.
DEFINE TEMP-TABLE TmpTab NO-UNDO LIKE Bank.Sysc
    INDEX sysc sysc
    INDEX ID Id
    .
DEF BUFFER bf_Tmp FOR TmpTab.
DEF BUFFER bfTmp FOR TmpTab.
DEFINE QUERY qRep FOR TmpTab.
DEFINE BROWSE bRep QUERY qRep DISPLAY
    TmpTab.SysC  FORMAT "X(10)"          /*LABEL "Kods"*/
    TmpTab.Des   FORMAT "X(25)"          /*LABEL "Apraksts"*/
    TmpTab.DaVal FORMAT "99.99.9999"       /*LABEL "Pri"*/
    TmpTab.DeVal FORMAT "->>>>>>>>>9.99"  /*LABEL "Liet." */
    TmpTab.InVal FORMAT ">>>>>>>>>9"
    TmpTab.LoVal
    TmpTab.ChVal FORMAT "X(70)"
    WITH 16 DOWN NO-BOX SIZE 78 BY 18.
DEFINE FRAME Mf
    bRep HELP "Ins/F6 - Add/Edit values; Del - Delete;"
    WITH SIZE 80 BY 20 NO-LABELS CENTERED OVERLAY
    ROW PosY
    TITLE " SYSTEM PARAMETERS MANAGER " .
FRAME Mf:TITLE-DCOLOR = 1.
bRep:NUM-LOCKED-COLUMNS IN FRAME Mf = 1.
/*
-----------------------------------------------
TRIGGERS 
-----------------------------------------------
*/
ON ANY-PRINTABLE OF bRep
 DO:
     IF AVAILABLE TmpTab THEN f_Id = TmpTab.Id.
     IF lastkey >= 65 OR lastkey >= 48 THEN
      DO:
        IF LENGTH(fName) < 8 THEN
         DO:
            FIND FIRST bf_Tmp WHERE bf_Tmp.SysC BEGINS fName + CHR(lastkey)
                            NO-LOCK NO-ERROR.
            IF AVAILABLE bf_Tmp THEN 
             DO: 
                fName = fName + CHR(lastkey).
                f_Id = bf_Tmp.Id.
                RUN Reposition.
                MESSAGE fName.
             END.
            ELSE
             DO:
                f_Id = 0.
             END.
         END.
      END.
               
    RUN ShowMf.
 END.                                       
ON BACKSPACE OF bRep
 DO:
    IF fName <> "" THEN
     DO:
        fName = SUBSTRING(fName, 1, LENGTH(fName) - 1).
        FIND FIRST bf_Tmp WHERE bf_Tmp.SysC BEGINS fName
                        NO-LOCK NO-ERROR.
        IF AVAILABLE bf_Tmp THEN
         DO:
           f_Id = bf_Tmp.Id.
           RUN Reposition.
         END.
     END.
     MESSAGE fName.
 END.
ON VALUE-CHANGED, CURSOR-UP, CURSOR-DOWN, PAGE-UP, PAGE-DOWN OF bRep
 DO:
    fName = "".
    HIDE MESSAGE NO-PAUSE.
    IF NOT AVAILABLE TmpTab THEN LEAVE.
    f_Id = TmpTab.Id.
 END.
ON RETURN OF bRep
 DO:
    IF NOT AVAILABLE TmpTab THEN Leave.
    RUN DisableMf.
    f_Id = TmpTab.Id.
    e_SysC = TmpTab.SysC.
    RUN sysc_edit_it.p(INPUT-OUTPUT e_SysC, 1).
    RUN Recordset.
    RUN ShowMf.
 END.
ON INSERT OF bRep
 DO:
      e_SysC = "".
      RUN DisableMf.
      RUN sysc_edit_it.p(INPUT-OUTPUT e_SysC, 0).
      fName = e_SysC.
      RUN Recordset.
      RUN ShowMf.
 END.
 
ON F5 OF bRep
 DO:
 END.
                       
ON F6 OF bRep
 DO:
    IF NOT AVAILABLE TmpTab THEN Leave.
    RUN DisableMf.
    f_Id = TmpTab.Id.
    e_SysC = TmpTab.SysC.
    RUN sysc_edit_it.p(INPUT-OUTPUT e_SysC, 0).
    RUN Recordset.
    RUN ShowMf.
 END.
ON F8, PF8 OF bRep
 DO:
    IF NOT AVAILABLE TmpTab THEN Leave.
 END.
ON DEL OF bRep
 DO:
    IF NOT AVAILABLE TmpTab THEN Leave.
    answ = no.
    MESSAGE COLOR "YELLOW/BLACK" 
            "Are you sure to delete system parameter: " 
            TmpTab.SysC
            skip TmpTab.Des
            VIEW-AS ALERT-BOX  
            BUTTONS YES-NO 
            TITLE "SysC manager"
            UPDATE answ
            .
    IF Answ = Yes THEN
     DO:
        FIND FIRST bf_Sysc WHERE bf_Sysc.SysC = TmpTab.SysC NO-ERROR.
        IF AVAILABLE bf_Sysc THEN DELETE bf_Sysc.
        RUN Recordset.
        RUN ShowMf.
     END.
 END.
ON PF4, F4 OF FRAME Mf RUN HideMf.
IF f_SysC <> "" THEN
 DO:
     FIND FIRST bf_SysC WHERE bf_SysC.SysC = f_Sysc NO-LOCK NO-ERROR.
     IF AVAILABLE bf_Sysc THEN fName = bf_Sysc.SysC.
 END.
RUN ShowMf.
RUN Recordset.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW OR PF4, F4 OF FRAME Mf.
RUN HideMf.
/*
------------------------------------------------------
MAIN BLOCK
------------------------------------------------------
*/
/*********************************************************/
/*** DELETING ALL PARAMETERS BY IT's PARENT IDENTIFIER ***/
/*********************************************************/
DEF VAR Lnn AS INT64.
DEF VAR Sys_RecItr AS INT64 INIT 17.
PROCEDURE Recordset:
    FOR EACH TmpTab: DELETE TmpTab. END.
    Rez = 1.
    IF f_Sysc <> "" THEN
     DO:
        IF AVAILABLE bf_Sysc THEN
         DO:
            FIND FIRST TmpTab WHERE  TmpTab.SysC = bf_Sysc.SysC 
                          NO-LOCK NO-ERROR.
            IF NOT AVAILABLE TmpTab THEN CREATE TmpTab.
            BUFFER-COPY bf_Sysc TO TmpTab.
            RUN Rec_Refresh.
         END.
     END.
    e_Id = 0.        
    FOR EACH bf_Sysc NO-LOCK USE-INDEX SysC:
        CREATE bfTmp.
        BUFFER-COPY bf_Sysc TO bfTmp.
        PROCESS EVENTS.
        Lnn = Lnn + 1.
        IF Lnn > Sys_RecItr THEN 
         DO:
            IF      Sys_RecItr < 20   THEN Sys_RecItr = 1000.
            Lnn = 0.
            RUN Rec_Refresh.
         END.
    END.
    RUN Rec_Refresh.
END PROCEDURE.
PROCEDURE Rec_Refresh:
    OPEN QUERY qRep FOR EACH TmpTab.
    RUN Reposition.
END.
        
PROCEDURE Reposition:
    DEF BUFFER bfTmpTab FOR TmpTab.
    IF fName <> "" THEN 
     DO:
        FIND FIRST bfTmpTab WHERE bfTmpTab.SysC BEGINS fName
            NO-LOCK NO-ERROR.
        MESSAGE fName.
     END.
    ELSE IF f_Id <> 0 THEN
        FIND bfTmpTab WHERE bfTmpTab.Id = f_Id NO-LOCK NO-ERROR.
    ELSE
        FIND FIRST bfTmpTab  NO-LOCK NO-ERROR.
    IF AVAILABLE bfTmpTab THEN
     DO:
         bRep:SET-REPOSITIONED-ROW(7, "CONDITIONAL") IN FRAME Mf.
         REPOSITION qRep TO RECID recid(bfTmpTab) NO-ERROR.
     END.
END PROCEDURE.
PROCEDURE ShowMf:
    ENABLE ALL WITH FRAME Mf. PAUSE 0.
    MESSAGE fName.
END PROCEDURE.
PROCEDURE HideMf:
    DISABLE ALL WITH FRAME Mf.
    HIDE FRAME Mf. PAUSE 0.
END PROCEDURE.
PROCEDURE DisableMf:
    DISABLE ALL WITH FRAME Mf.  PAUSE 0.
    DISABLE ALL WITH FRAME MfSh. PAUSE 0.
    DISABLE ALL WITH FRAME MfSh. PAUSE 0.
END PROCEDURE.