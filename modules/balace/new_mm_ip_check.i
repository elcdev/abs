FUNCTION Get_Dept_Nod_From_Dpt CHAR (input idpt as INT):
    FIND FIRST dept where dept.dept eq idpt no-lock no-error.
    if available dept then return dept.Nodala_Code.
    return "".
END.
FUNCTION Get_IP_Address CHAR ():
    DEF VAR SSH_Host_IP AS CHAR NO-UNDO.
    DEF VAR cfso AS sysfso NO-UNDO.
    cfso = NEW sysfso().
    
    /*SSH_Host_IP = cfso:Get_IP_2X().*/
    /*SSH_Host_IP = entry(1, os-getenv("SSH_CLIENT"), " ").*/
    SSH_Host_IP = cfso:Get_IP_Address().
    
    DELETE OBJECT cfso NO-ERROR.
    RETURN SSH_Host_IP.
END.
DEF VAR SSH_Host_IP         AS CHAR NO-UNDO.
DEF VAR OFC_BRA_UNICAT      AS CHAR NO-UNDO.
DEF VAR OFC_BRA_UNICAT_INT  AS INT  NO-UNDO.
DEF VAR OFC_BRA_WS          AS CHAR NO-UNDO.
DEF VAR OFC_BRA_WS_INT      AS INT  NO-UNDO.
DEF VAR OFC_BRA_WS_DEPT     AS INT  NO-UNDO.
OFC_BRA_UNICAT = "(не найдено)".
OFC_BRA_WS     = "(не найдено)".
OFC_BRA_UNICAT_INT = ?.
OFC_BRA_WS_INT     = ?.
FIND FIRST ofc WHERE ofc.ofc EQ os-getenv("LOGNAME") NO-LOCK NO-ERROR.
IF AVAILABLE ofc AND ofc.ofc NE ? AND ofc.ofc NE "" THEN DO:
    OFC_BRA_WS_INT = ofc.bra.
    OFC_BRA_WS_DEPT = ofc.dpt.
    FIND FIRST bra WHERE bra.bra EQ ofc.bra NO-LOCK NO-ERROR.
    IF AVAILABLE bra THEN OFC_BRA_WS = bra.name.
END.
DEF VAR BRA_CHECK_ENABLE    AS LOG  NO-UNDO.
DEF VAR MAIN_Dept_Nod       AS CHAR NO-UNDO.
DEF VAR OFC_Dept_Nod        AS CHAR NO-UNDO.
BRA_CHECK_ENABLE = FALSE.

IF OFC_BRA_WS_INT NE 1 THEN BRA_CHECK_ENABLE = FALSE.
ELSE DO:
    OFC_Dept_Nod = Get_Dept_Nod_From_Dpt(OFC_BRA_WS_DEPT).
    MAIN_Dept_Nod = TRIM(Get_Dept_Nod_From_Dpt(5875), "0"). /*В прямом подчинении Вице-президента*/
    IF OFC_Dept_Nod BEGINS MAIN_Dept_Nod 
    AND OFC_BRA_WS_DEPT NE 3820
    AND OFC_BRA_WS_DEPT NE 3750
    AND OFC_BRA_WS_DEPT NE 380
    AND OFC_BRA_WS_DEPT NE 4220
    THEN BRA_CHECK_ENABLE = FALSE.
END.

IF BRA_CHECK_ENABLE THEN DO:    
    SSH_Host_IP = Get_IP_Address().
    FIND FIRST UNICAT WHERE unicat.catid EQ "BRA_IP"
    AND unicat.field1 EQ SSH_Host_IP NO-LOCK NO-ERROR.
    IF NOT AVAILABLE UNICAT THEN FIND FIRST UNICAT WHERE unicat.catid EQ "BRA_IP"
    AND replace(SSH_Host_IP, ".", ":") MATCHES TRIM(replace(unicat.field1, ".", ":")) NO-LOCK NO-ERROR.
    IF AVAILABLE UNICAT THEN DO:
        OFC_BRA_UNICAT_INT = INT(unicat.field2) NO-ERROR.
        IF OFC_BRA_UNICAT_INT NE ? AND OFC_BRA_UNICAT_INT GT 0 THEN DO:
            FIND FIRST bra WHERE bra.bra EQ OFC_BRA_UNICAT_INT NO-LOCK NO-ERROR.
            IF AVAILABLE bra THEN OFC_BRA_UNICAT = bra.name.
        END.
    END.
    IF OFC_BRA_UNICAT_INT EQ ?
    OR OFC_BRA_UNICAT_INT EQ 0 
    OR OFC_BRA_WS_INT EQ ?
    OR OFC_BRA_WS_INT EQ 0
    OR OFC_BRA_UNICAT_INT NE OFC_BRA_WS_INT THEN DO:    
        /*проверка среди исключений*/
        FIND FIRST UNICAT WHERE unicat.catid eq "BRA_IP_SKIP"
        AND unicat.field1 EQ os-getenv("LOGNAME") 
        AND unicat.field1 NE ? AND unicat.field1 NE "" NO-LOCK NO-ERROR.
        IF NOT AVAILABLE UNICAT THEN DO:
            IF OFC_BRA_UNICAT EQ "(не найдено)" THEN OFC_BRA_UNICAT = SSH_Host_IP.
            IF OFC_BRA_UNICAT EQ ? OR OFC_BRA_UNICAT EQ "" THEN OFC_BRA_UNICAT = "( не найдено )".
            MESSAGE COLOR m "Вы закреплены за фил./расч.группой: " OFC_BRA_WS skip
            "Ваша рабочая станция закреплена за фил./расч.группой: " OFC_BRA_UNICAT skip
            "Обратитесь к своему прямому руководителю для перевода на правильный" skip
            "филиал/расчетную группу!" VIEW-AS ALERT-BOX.
            IF g-ofc NE "alechi" THEN RETURN.
        END.        
    END.
END.
