CLASS stringApi:
    DEF VAR f_MnDays AS INT64 NO-UNDO EXTENT 12.
    DEF VAR B64STR AS CHAR NO-UNDO CASE-SENSITIVE.
    
    CONSTRUCTOR stringApi():
        f_MnDays[1]  = 31.
        f_MnDays[2]  = 28.
        f_MnDays[3]  = 31.
        f_MnDays[4]  = 30.
        f_MnDays[5]  = 31.
        f_MnDays[6]  = 30.
        f_MnDays[7]  = 31.
        f_MnDays[8]  = 31.
        f_MnDays[9]  = 30.
        f_MnDays[10] = 31.
        f_MnDays[11] = 30.
        f_MnDays[12] = 31.
        B64STR = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".
        FillOnlyChars().
    END.

    DESTRUCTOR stringApi():
    
    END.

/****************************************************************************/
/** CONVERTS DATE INTO FIRST MONTH DATE   ***********************************/
/****************************************************************************/
METHOD PRIVATE DATE FM_Date (Dt AS DATE):
    RETURN DATE(Month(Dt),1, Year(Dt)).
END.

/***************************************************************************/
/** CONVERTS DATE INTO LAST MONTH DATE *************************************/
/***************************************************************************/
METHOD PRIVATE DATE LM_Date (Dt AS DATE):
    DEF VAR Mn  AS INT NO-UNDO.
    DEF VAR Yr  AS INT NO-UNDO.
    Yr = Year(Dt).
    Mn = Month(Dt) + 1.
    IF Mn = 13 THEN DO: Mn = 1. Yr = Yr + 1. END.
    RETURN (DATE(Mn,1,Yr) - 1).
END.

/****************************************************************************/
/*** CONVERTS TIME INTO STRING VALUE ****************************************/
/****************************************************************************/
METHOD PRIVATE CHAR Get_Time_Str(f_Time AS INT64):
    DEF VAR Val AS CHAR NO-UNDO.
    Val = STRING(f_Time, "hh:mm:ss") NO-ERROR.
    RETURN Val.
END.

/***************************************************************************/
/*** CONVERTS CURRENT TIME INTO STRING VALUE *******************************/
/***************************************************************************/
METHOD PRIVATE CHAR Get_TimeS():
    DEF VAR Val AS CHAR NO-UNDO.
    Val = Get_Time_Str(time).
    RETURN Val.
END.

/***************************************************************************/
/*** TIME FORMATING FUNCTION ***********************************************/
/***************************************************************************/
METHOD PUBLIC CHAR CFormat(f_Time AS INT64, f_Format AS CHAR):
    IF INDEX(f_Format, ":") > 0 OR INDEX(f_Format, "M") > 0 
    OR INDEX(f_Format, "h") > 0 OR INDEX(f_Format, "s") > 0 THEN
        RETURN FormatTime(f_Time, f_Format).
    ELSE
        RETURN STRING(f_Time, f_Format).
END.

METHOD PRIVATE CHAR FormatTime(f_Time AS INT64, f_Format AS CHAR):
    DEF VAR MM  AS CHAR NO-UNDO.
    DEF VAR HH  AS CHAR NO-UNDO.
    DEF VAR SS  AS CHAR NO-UNDO.
    
    DEF VAR ts  AS CHAR NO-UNDO.
    DEF VAR Str AS CHAR NO-UNDO.
    ts = STRING(f_Time, "hh:mm:ss") NO-ERROR.
    HH = SUBSTRING(ts, 1, 2) NO-ERROR.
    MM = SUBSTRING(ts, 4, 2) NO-ERROR.
    SS = SUBSTRING(ts, 7, 2) NO-ERROR.
    Str = f_Format.
    Str = Replace(Str, "HH", TRIM(HH)).
    Str = Replace(Str, "MM", TRIM(MM)).
    Str = Replace(Str, "SS", TRIM(SS)).
    RETURN Str.
END.

/*****************************************************************************/
/*** RETURNS DATE VALUE FROM STRING BY FORMAT STRING *************************/
/*** CONVERTS STRING DATE INTO DATE VALUE ************************************/
/*****************************************************************************/
METHOD PRIVATE DATE Get_Date_By_Str(f_Dt AS CHAR, f_Fomat AS CHAR):
    DEF VAR YY AS INT64 NO-UNDO.
    DEF VAR MM AS INT64 NO-UNDO.
    DEF VAR DD AS INT64 NO-UNDO.
    DEF VAR C  AS INT64 NO-UNDO.
    DEF VAR F  AS INT64 NO-UNDO.
    DEF VAR Val AS DATE NO-UNDO.
    DEF VAR DLM AS CHAR NO-UNDO.
    
    IF f_Dt = "" OR f_Dt = ? THEN RETURN ?.
    /*** DETECTING MONTH BY FORMAT STRING ***/
    C = INDEX(f_Fomat, "mm").
    IF C > 0 THEN
     DO:
        MM = int64(SUBSTRING(f_Dt,c,2)) NO-ERROR.
        IF MM < 1 OR MM > 12 THEN c = -1.
     END.
    ELSE
     DO:
        C = INDEX(f_Fomat, "m").
        IF C > 0 THEN
         DO:
            /* POISK RAZDELITELJA */
            IF INDEX(f_Fomat, "/") > 0 THEN DLM = "/".
            ELSE IF INDEX(f_Fomat, ".") > 0 THEN DLM = ".".
            /* RAZBORKA S POMOSHJU RAZDELITELJA */
            DEF VAR sMm AS INT64 NO-UNDO.
            DEF VAR sDd AS INT64 NO-UNDO.
            DEF VAR sYy AS INT64 NO-UNDO.
            DEF VAR sEn AS INT64 NO-UNDO.
            f_Dt = ENTRY(1, f_Dt, " ").
            DO sEn = 1 TO 3:
                IF INDEX(ENTRY(sEn, f_Fomat, DLM), "y") > 0 THEN 
                 DO:
                    Yy = int64(ENTRY(sEn, f_Dt, DLM)) NO-ERROR.
                 END.
                 
                ELSE IF INDEX(ENTRY(sEn, f_Fomat, DLM), "m") > 0 THEN 
                 DO:
                    Mm = int64(ENTRY(sEn, f_Dt, DLM)) NO-ERROR.
                 END.
                ELSE IF INDEX(ENTRY(sEn, f_Fomat, DLM), "d") > 0 THEN
                 DO:
                    Dd = int64(ENTRY(sEn, f_Dt, DLM)) NO-ERROR.
                 END.
            END.
            
            IF MM < 1 OR MM > 12 THEN 
             DO:
                MESSAGE "(stringApi.cls:GET_DATE_BY_STR) Motnh is out of range!"
                    f_Dt  VIEW-AS ALERT-BOX.
             END.
            IF DD < 1 OR DD > 31 THEN 
             DO:
                MESSAGE "(string.f:GET_DATE_BY_STR) Date is out of range!" f_Dt
                    VIEW-AS ALERT-BOX.
             END.
            Val = DATE(MM,DD,YY) NO-ERROR.
            IF Val = ? THEN
             DO:
                MESSAGE "(string.f:GET_DATE_BY_STR) Date is incorrect! " f_Dt
                 VIEW-AS ALERT-BOX.
             END.
            RETURN Val.
         END.
     END.
     
    
    IF C <= 0 THEN 
     DO:
        MM = MONTH(today).
        f = f + 10.
     END.
     
    /*** DETECTING YEAR IN STRING BY FORMAT STRING ***/
    C = INDEX(f_Fomat, "yyyy").
    IF C <= 0 THEN 
     DO:
       C  = INDEX(f_Fomat, "yy").
       IF C <= 0 THEN
        DO:
            C = INDEX(f_Fomat, "y").
            YY = YEAR(today).
            f = f + 1.
        END.
       ELSE
        DO:
            YY = int64(ENTRY(1, SUBSTRING(f_Dt, c, 2), " ")) NO-ERROR.
            /************************************************************/
            /*** CONWECTIRUEM STOLETIJE DATY ***************************/
            /************************************************************/
            IF YY < (YEAR(today) MOD 100) + 50 THEN 
                YY = TRUNCATE(YEAR(today) / 100,0) * 100 + YY. 
            ELSE 
                YY = (TRUNCATE(YEAR(today) / 100, 0) - 1) * 100 + YY.
            /*MESSAGE YY VIEW-AS ALERT-BOX.*/
        END.
     END.
    ELSE
     DO:
        /* Vytaskivajem god, uchityvajem, chto posle goda mozhet idti vremja cherez probel */
        YY = int64(ENTRY(1, SUBSTRING(f_Dt, c, 4), " ")) NO-ERROR.
     END.
     
    IF YY < 100 THEN YY = YY + 2000.
    
    /*** DETECTING DAY BY FORMAT STRING ***/
    C = INDEX(f_Fomat, "dd").
    IF C > 0  THEN
     DO:
        DD = int64(SUBSTRING(f_Dt,c,2)) NO-ERROR.
        IF DD < 1 OR DD > 31 THEN c = -1.
     END.
    ELSE
     DO:
        C = INDEX(f_Fomat, "d").
        IF C > 0  THEN
         DO:
            DD = int64(SUBSTRING(f_Dt,c,1)) NO-ERROR.
            IF DD < 1 OR DD > 31 THEN c = -1.
         END.
     END.
    IF C <= 0 THEN 
     DO:
        DD = DAY(today).
        f = f + 100.
     END.
    IF f < 10 THEN Val = DATE(MM,DD,YY).
    ELSE Val = ?.
    RETURN Val.
END.

/***************************************************************************/
/*** UNIVERSAL DATE AND TIME FORMATING FUNCTION ****************************/
/***************************************************************************/
DEF VAR MDES   AS CHAR EXTent 60 NO-UNDO. 
DEF VAR MDESOK AS INT64            NO-UNDO.

METHOD PUBLIC CHAR CFormat
(
  INPUT Dt        AS DATE,      /* Date value          */
  INPUT f_Time    AS INT64,     /* Time value          */
  INPUT FormatStr AS CHAR       /* Format String       */
 ):
    RETURN FormatDateTime(Dt, f_Time, 0, FormatStr).
END.

METHOD PUBLIC CHAR CFormat(Dt AS DATETIME, FormatStr AS CHAR):
    RETURN CFormat(DATETIME-TZ(Dt), FormatStr).
END.

METHOD PUBLIC CHAR CFormat(Dt AS DATETIME-TZ, FormatStr AS CHAR):
    DEF VAR Mt AS INT  NO-UNDO.
    DEF VAR Tm AS INT  NO-UNDO.
    DEF VAR DD AS DATE NO-UNDO.
    MT = MTIME(dt) MOD 1000.
    Tm = (MTIME(dt) - MT) / 1000.
    RETURN FormatDateTime(Date(Dt), Tm, MT, FormatStr).
END.


METHOD PRIVATE CHAR FormatDateTime
(
  INPUT Dt        AS DATE,      /* Date value          */
  INPUT f_Time    AS INT64,     /* Time value          */
  INPUT FormatStr AS CHAR       /* Format String       */
  
 ):
    RETURN FormatDateTime(Dt, f_Time, 0, FormatStr).
END.

METHOD PRIVATE CHAR FormatDateTime
(
  INPUT Dt        AS DATE,      /* Date value          */
  INPUT f_Time    AS INT64,     /* Time value          */
  INPUT f_Tttt    AS INT64,     /* Miliseconds         */
  INPUT FormatStr AS CHAR       /* Format String       */
  
 ):
  DEF VAR sDd  AS CHAR NO-UNDO.
  DEF VAR sMn  AS CHAR NO-UNDO.
  DEF VAR sYr1 AS CHAR NO-UNDO.
  DEF VAR sYr2 AS CHAR NO-UNDO.
  DEF VAR Str  AS CHAR NO-UNDO.
  IF Dt = ? THEN RETURN "".
  IF MDESOK = 0 THEN 
   DO:
      MDESOK = 1.
     /* NOMINATIVS ... */
      MDES[1] = "Janvāris".
      MDES[2] = "Februāris".
      MDES[3] = "Marts".
      MDES[4] = "Aprīlis".
      MDES[5] = "Maijs".
      MDES[6] = "Jūnijs".
      MDES[7] = "Jūlijs".
      MDES[8] = "Augusts".
      MDES[9] = "Septembris".
      MDES[10] = "Oktobris".
      MDES[11] = "Novembris".
      MDES[12] = "Decembris".

     /* PAR ... */
      MDES[13] = "Janvāri".
      MDES[14] = "Februāri".
      MDES[15] = "Martu".
      MDES[16] = "Aprīli".
      MDES[17] = "Maiju".
      MDES[18] = "Jūniju".
      MDES[19] = "Jūliju".
      MDES[20] = "Augustu".
      MDES[21] = "Septembri".
      MDES[22] = "Oktobri".
      MDES[23] = "Novembri".
      MDES[24] = "Decembri".

    /* NO ... */
      MDES[25] = "Janvāra".
      MDES[26] = "Februāra".
      MDES[27] = "Marta".
      MDES[28] = "Aprīla".
      MDES[29] = "Maija".
      MDES[30] = "Jūnija".
      MDES[31] = "Jūlija".
      MDES[32] = "Augusta".
      MDES[33] = "Septembra".
      MDES[34] = "Oktobra".
      MDES[35] = "Novembra".
      MDES[36] = "Decembra".

    /* LIDZ ... */
      MDES[37] = "Janvārim".
      MDES[38] = "Februārim".
      MDES[39] = "Martam".
      MDES[40] = "Aprīlim".
      MDES[41] = "Maijam".
      MDES[42] = "Jūnijam".
      MDES[43] = "Jūlijam".
      MDES[44] = "Augustam".
      MDES[45] = "Septembrim".
      MDES[46] = "Oktobrim".
      MDES[47] = "Novembrim".
      MDES[48] = "Decembrim".

    /* KUR ... */                          
      MDES[49] = "Janvārī".
      MDES[50] = "Februārī".
      MDES[51] = "Martā".
      MDES[52] = "Aprīlī".
      MDES[53] = "Maijā".
      MDES[54] = "Jūnijā".
      MDES[55] = "Jūlijā".
      MDES[56] = "Augustā".
      MDES[57] = "Septembrī".
      MDES[58] = "Oktobrī".
      MDES[59] = "Novembrī".
      MDES[60] = "Decembrī".
   END.
  /* OPTIMIZACIONNYJE PARAMETRY FUNKCII - USKORENIJE V 7-8 RAZ */
  /* PRI DOBAVLENII NOVYH REZHIMOV - SLEDITE ZA OPTIMIZACIJEJ  */
  /* CHASTJ PEREMENNYJ VZVODJATSJA V PROCESSE VYPOLNENIJA !!!  */
  
  DEF VAR IM   AS INT64 NO-UNDO.
  DEF VAR IMMM AS INT64 NO-UNDO.
  DEF VAR IH   AS INT64 NO-UNDO.
  DEF VAR ISS  AS INT64 NO-UNDO.
  DEF VAR ID   AS INT64 NO-UNDO.
  DEF VAR IY   AS INT64 NO-UNDO.
  
  IM   = INDEX(FormatStr, "m").
  IF IM > 0 THEN 
   DO:
    IMMM = INDEX(FormatStr, "mmm").
    sMn  = STRING(Month(Dt), "99").
   END.
  IH   = INDEX(FormatStr, "h").
  ISS  = INDEX(FormatStr, "s").
  ID   = INDEX(FormatStr, "d").
  IY   = INDEX(FormatStr, "y").
  Str = FormatStr.
  IF IH > 0 THEN
   DO:
        IF ISS > 0 THEN
         DO:
          Str = Replace(Str, "hh:mm:ss", FormatTime(f_time,"hh:mm:ss")).
          Str = Replace(Str, "hhmmss",   FormatTime(f_time,"hhmmss")).
         END.
        IF IM > 0 THEN
         DO:
          Str = Replace(Str, "hh:mm",    FormatTime(f_time,"hh:mm")).
          Str = Replace(Str, "hhmm",     FormatTime(f_time,"hhmm")).
         END.
        Str = Replace(Str, "hh",       FormatTime(f_time,"hh")).
   END.   

   IF ISS > 0 THEN
    DO:
      IF IM > 0 THEN
       DO:
          Str = Replace(Str, "mm:ss",    FormatTime(f_time,"mm:ss")).
          Str = Replace(Str, "mmss",     FormatTime(f_time,"mmss")).
       END.
      Str = Replace(Str, "ss",       FormatTime(f_time,"ss")).
   END.
   IF f_Tttt >  0 THEN
    DO:
        Str = Replace(Str, "ttt", TRIM(STRING(f_Tttt))).
    END.

   IF ID  > 0 THEN 
    DO:
        sDd  = STRING(DAY(Dt), "99").
        Str = Replace(Str, "dd",   sDd).
    END.
   IF IM > 0 THEN
    DO:
      IF IMMM > 0 THEN
       DO:
          Str = Replace(Str, "mmmm", MDES[Month(Dt)]).
          Str = Replace(Str, "mmmp", MDES[Month(Dt) + 12]).
          Str = Replace(Str, "mmmn", MDES[Month(Dt) + 24]).
          Str = Replace(Str, "mmml", MDES[Month(Dt) + 36]).
          Str = Replace(Str, "mmmk", MDES[Month(Dt) + 48]).
          Str = Replace(Str, "mmm",  SUBSTRING(MDES[Month(Dt)],1,3)).
       END.
      Str = Replace(Str, "mi",   FormatTime(f_time,"mm")).
      Str = Replace(Str, "mm",   sMn).
    END.
   IF IY > 0 THEN
    DO:
      sYr1 = STRING(Year(Dt), "9999").
      sYr2 = sYr1.
      sYr1 = SUBSTRING(sYr1, 3, 4).

      Str = Replace(Str, "yyyy", sYr2).
      Str = Replace(Str, "yy",   sYr1).
    END.
  RETURN Str.
END.

/****************************************************************************/
/*** DATE FORMATING FUNCTION ************************************************/
/****************************************************************************/
METHOD PUBLIC CHAR CFormat
(
    INPUT Dt     AS DATE,         /* Date value          */
    INPUT FormatStr AS CHAR       /* Format String       */
):
    RETURN FormatDateTime(Dt, 0, 0, FormatStr).
END.


METHOD PRIVATE CHAR FormatDate
(
    INPUT Dt     AS DATE,         /* Date value          */
    INPUT FormatStr AS CHAR       /* Format String       */
):
    RETURN FormatDateTime(Dt, 0, 0, FormatStr).
END.

/****************************************************************************/
/*** PUTS ELEMENT INTO GIVEN POSITION IN STRING SEPARATED BY DELIMITER  *****/
/****************************************************************************/
METHOD PRIVATE CHAR Set_Entry(f_Pos AS INT64,    /* Position in string       */
                                f_Str AS CHAR,   /* Result string where ...  */
                                f_Delim AS CHAR, /* Entries delimiter        */
                                f_Item AS CHAR): /* Item to insert in string */
    DEF VAR Ne AS INT64 NO-UNDO.
    DEF VAR St AS CHAR  NO-UNDO.
    DEF VAR Re AS CHAR  NO-UNDO.
    DEF VAR I  AS INT64 NO-UNDO.
    Ne = NUM-ENTRIES(f_Str, f_Delim) NO-ERROR.
    DO Ne = Ne TO f_Pos - 1:
        f_Str = f_Str + f_Delim.
    END.
    DO I = 1 TO Ne:
        /*If I > 1 THEN Re = Re + f_Delim.*/
        If I <> f_Pos THEN
            St = ENTRY(I,f_Str,f_Delim) NO-ERROR.
        ELSe
            St = f_Item.
        Re = Re + St + f_Delim.
    END.
    Re = SUBSTRING(Re, 1, LENGTH(Re) - 1).
    RETURN Re.    
END.

/****************************************************************************/
/** CONVERTS DECIMAL NUMBER TO HEXADECIMAL NUMBER ***************************/
/****************************************************************************/
METHOD PRIVATE CHAR TO_HEX_E (N AS DEC, LZ AS INT64, BASE AS INT64):
    DEF VAR r   AS INT64       NO-UNDO.
    DEF VAR b   AS DEC INIT 16 NO-UNDO.
    DEF VAR CN  AS DEC         NO-UNDO.
    DEF VAR Val AS CHAR        NO-UNDO.
    DEF VAR SS  AS CHAR        NO-UNDO.
    IF BASE <= 1 THEN b = 16. ELSE b = base.
    DO WHILE N > 0:
        SS = STRING(N / B, "->>>>>>>>>>>>>>>>>9.999999999").
        CN = DEC(ENTRY(1, SS, ".")) NO-ERROR.
        R  = N - CN * B.
        IF R < 0 THEN 
         DO:
            R = 0.
         END.
        N = CN.
        IF r < 10 THEN SS = STRING(r).
                  ELSE SS = CHR(r + ASC('A') - 10).
        Val = SS + Val.
    END.
    
    IF Val = "" THEN Val = "0".
    IF LENGTH(Val) < LZ THEN
     DO:
        Val = FILL("0", LZ - LENGTH(Val)) + Val.
     END.
    RETURN Val.
END.

DEF PRIVATE VAR Align_LEFT   AS INT64 INIT 0 NO-UNDO.
DEF PRIVATE VAR Align_CENTER AS INT64 INIT 1 NO-UNDO.
DEF PRIVATE VAR Align_RIGHT  AS INT64 INIT 2 NO-UNDO.

METHOD PRIVATE CHAR Set_SubString(   f_Str     AS CHAR,
                                        f_SetStr  AS CHAR,
                                        f_SetX    AS INT64,
                                        f_SetLEN  AS INT64,
                                        f_Align   AS INT64 /* 0,1,2 */
                                    ):
    DEF VAR sl AS INT64 NO-UNDO.
    DEF VAR s  AS CHAR  NO-UNDO.
    IF f_SetX <= 0 THEN
     DO:
        MESSAGE "Position must bee >0!" VIEW-AS ALERT-BOX.
        RETURN f_Str.
     END.

    IF f_SetLEN < 0 THEN
        f_SetLEN = LENGTH(f_SetStr).
    
    sl = LENGTH(f_Str).
    IF sl < f_SetX + f_SetLEN THEN
        f_Str = f_Str + FILL(" ", f_SetX + f_SetLEN - Sl - 1).
    IF LENGTH(f_SetStr) >= f_SetLEN THEN
     DO:
        IF f_Align = Align_RIGHT THEN
            f_SetStr = SUBSTRING(f_SetStr, LENGTH(f_SetStr) - f_SetLEN + 1,
                                 f_SetLEN).
        ELSE
            f_SetStr = SUBSTRING(f_SetStr, 1, f_SetLEN).
        S = f_SetStr.
     END.
    ELSE 
     DO:
        s = FILL(" ", f_SetLEN - LENGTH(f_SetStr)).
        IF f_Align = Align_LEFT THEN
            s = f_SetStr + s. /* LEFT */
        ELSE IF f_Align = Align_RIGHT THEN
            s = s + f_SetStr. /* RIGHT */
        ELSE IF f_Align = Align_CENTER THEN
         DO:                  /* CENTER */
            DEF VAR s1 AS CHAR NO-UNDO.
            DEF VAR s2 AS CHAR NO-UNDO.
            s1 = SUBSTRING(s, 1, int64(LENGTH(s) / 2)).
            s2 = SUBSTRING(s, 1, int64(LENGTH(s) - LENGTH(s1))).
            s = s1 + f_SetStr + s2.
         END.
        ELSE
            MESSAGE "Unknown aligment!" VIEW-AS ALERT-BOX.
        
     END.
     f_Str = SUBSTRING(f_Str, 1, f_SetX - 1) + S +
             SUBSTRING(f_Str, f_SetX + f_SetLEN).
     RETURN f_Str.
END. /* Set_SubString */


METHOD PRIVATE DEC Get_MonthCount(f_Nd AS DATE, f_Ld AS DATE, f_Mode AS INT64):
    /*
        RETURNS NUMBER OF MONTHS BETWIN DATES f_Nd AND f_Ld
        f_Mode Set's mode of returned value
        If f_Mode = 0: Function returns int64 number of month  
                        (50 days = 2 months)
        If f_Mode = 1: Function returns decimal number of months
                        (50 days = 1.65 month)
        If f_Mode = 2: Function returns decimal number of months
                        (50 days = 1 month)
                        
    */
    DEF VAR r_Val AS INT64 NO-UNDO.
    DEF VAR Dt    AS DATE  NO-UNDO.
    DEF VAR pDt   AS DATE  NO-UNDO.
    DEF VAR f_Sgn AS INT64 NO-UNDO. 
    DEF VAR f_Day AS INT64 NO-UNDO.
    DEF VAR f_Nm  AS DEC   NO-UNDO.
    DEF VAR f_Nmd AS DEC   NO-UNDO.
    IF f_Ld < f_Nd THEN
     DO:
        Dt = f_Ld.
        f_Ld = f_Nd.
        f_Nd = Dt.
        f_Sgn = -1.
     END.
    ELSE
        f_Sgn = 1.
    
    r_Val = 2.
    Dt    = f_Nd.
    f_Day = 1.
    f_Day = Day(f_Nd) NO-ERROR.
    /*message f_Nd f_Ld dt f_Day.*/
    DEF VAR f_Mn   AS INT64 NO-UNDO.
    DEF VAR f_Yr   AS INT64 NO-UNDO.
    DEF VAR ft_Day AS INT64 NO-UNDO.
    DEF VAR LMD    AS DATE  NO-UNDO.
    ft_Day = f_Day.
    DO WHILE Dt < f_Ld: 
        pDt = Dt.
        LMD  = LM_Date(Dt) + 1.
        f_Mn = Month(LMD).
        f_Yr = Year(LMD).
        IF f_Day > f_MnDays[f_Mn] THEN
            ft_Day = f_MnDays[f_Mn].
        ELSE
            ft_Day = f_Day.
        Dt = DATE(f_Mn, ft_Day, f_Yr).
        f_Nm = f_Nm + 1.
        /*MESSAGE f_Nm Dt VIEW-AS ALERT-BOX.*/
    END.
    IF f_Mode = 1 THEN
     DO:
        f_Nmd =  (f_Ld - pDt) / (Dt - pDt).
        IF f_Nmd > 0 THEN f_Nm = f_Nm - 1 + f_Nmd.
     END.
    ELSE IF f_Mode = 2 THEN f_Nm = f_Nm - 1.
    /*MESSAGE "Total:" f_Nm * f_Sgn f_Ld pDt Dt VIEW-AS ALERT-BOX.*/
    RETURN f_Nm * f_Sgn.                        
END.


METHOD PRIVATE DEC Get_YearCount (f_Nd AS DATE, f_Ld AS DATE, f_Mode AS INT64):
    /*
        RETURNS NUMBER OF MONTHS BETWIN DATES f_Nd AND f_Ld
        f_Mode Set's mode of returned value
        If f_Mode = 0: Function returns int64 number of month  
                        (50 days = 2 months)
        If f_Mode = 1: Function returns decimal number of months
                        (50 days = 1.65 month)
    */
    DEF VAR r_Val AS INT64  NO-UNDO.
    DEF VAR Dt    AS DATE NO-UNDO.
    DEF VAR pDt   AS DATE NO-UNDO.
    DEF VAR sDt   AS CHAR NO-UNDO.
    DEF VAR f_Day AS INT64  NO-UNDO.
    DEF VAR f_Mn  AS INT64  NO-UNDO.
    DEF VAR f_Nm  AS DEC  NO-UNDO.
    DEF VAR f_Nmd AS DEC  NO-UNDO.
    DEF VAR ft_Day AS INT64 NO-UNDO.
/*
    DEF VAR f_MnDays AS INT64 EXTENT 12 NO-UNDO.
    f_MnDays[1]  = 31.
    f_MnDays[2]  = 28.
    f_MnDays[3]  = 31.
    f_MnDays[4]  = 30.
    f_MnDays[5]  = 31.
    f_MnDays[6]  = 30.
    f_MnDays[7]  = 31.
    f_MnDays[8]  = 31.
    f_MnDays[9]  = 30.
    f_MnDays[10] = 31.
    f_MnDays[11] = 30.
    f_MnDays[12] = 31.
*/    
    r_Val = 2.
    Dt    = f_Nd.
    f_Day = Day(f_Nd).
    ft_Day = f_Day.
    
    f_Mn  = Month(f_Nd).
    DO WHILE Dt < f_Ld: 
        pDt = Dt.
        IF f_Day > f_MnDays[f_Mn] THEN
            ft_Day = f_MnDays[f_Mn].
        ELSE
            ft_Day = f_Day.
         Dt = DATE(f_Mn, ft_Day, Year(Dt) + 1).
        f_Nm = f_Nm + 1.
    END.
    IF f_Mode = 1 THEN
     DO:
        f_Nmd =  (f_Ld - pDt) / (Dt - pDt).
        IF f_Nmd > 0 THEN f_Nm = f_Nm - 1 + f_Nmd.
     END.
    RETURN f_Nm.                        
END.




/*
    AUTH: ALEZHU
    DATE: 22.05.2005
    DESC: STRING CONVERSION FUNCTIONS (CODEPAGES-CONVERSIONS)
*/

/*** PROTOTYPES ***/

/*
FUNCTION UHTM_TO_UTF8 CHAR(f_Str     AS CHAR) FORWARD.
FUNCTION DETECT_CP CHAR(f_Str AS CHAR) FORWARD.
FUNCTION sys_convert_str CHAR( f_Str AS CHAR,
                               f_To_CP AS CHAR,
                               f_From_Cp AS CHAR) FORWARD.
FUNCTION UCHR_TO_UTF8 CHAR(f_Asc AS INT64) FORWARD.
FUNCTION UTF8_TO_UHTM CHAR (f_Str AS CHAR) FORWARD.
FUNCTION KOI8_TO_UHTM CHAR (f_Str AS CHAR) FORWARD.
FUNCTION KOI8_TO_ENG  CHAR (f_Str AS CHAR) FORWARD.
*/
/*** FUNCTION BODIES ***/

/* TRANSLJUTERACIJA SIMVOLOV */
/*
METHOD PRIVATE CHAR KOI8_TO_ENG (f_Str AS CHAR):
    DEF VAR e_Str AS LONGCHAR NO-UNDO.
    DEF VAR e_Val AS CHAR     NO-UNDO.
    e_Str = f_Str.
    e_Val = KOI8_TO_ENG(e_Str).
    RETURN e_Val.
END.
*/
METHOD PRIVATE LONGCHAR KOI8_TO_ENG (f_Str AS LONGCHAR):
    DEF VAR e_Str AS CHAR     NO-UNDO.
    DEF VAR e_Val AS LONGCHAR NO-UNDO.
    e_Str = f_Str.
    e_Val = KOI8_TO_ENG(e_Str).
    RETURN e_Val.
END.

METHOD PRIVATE CHAR KOI8_TO_ENG (f_Str AS CHAR):
    DEF VAR f_KOI8 AS CHAR NO-UNDO CASE-SENSITIVE.
    DEF VAR f_ENG  AS CHAR NO-UNDO CASE-SENSITIVE.
    
    f_KOI8 = "1234567890-=+_/\\""':;,.<>()!@#$%^&*+".
    f_KOI8 = f_KOI8 + "abcdefghijklmnoprstuqvwxyz".
    f_KOI8 = f_KOI8 + "ABCDEFGHIJKLMNOPRSTUQVWXYZ".
    f_KOI8 = f_KOI8 + "ēūīāšģķļžčņ".
    f_KOI8 = f_KOI8 + "ĒŪĪĀŠĢĶĻŽČŅ".
    f_KOI8 = f_KOI8 + "абвгдежзийклмнопрстуфхцчшщьыъэюя".
    f_KOI8 = f_KOI8 + "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ".
    
    f_ENG  = "1234567890-=+_/\\""':;,.<>()!@#$%^&*+".
    f_ENG  = f_ENG  + "abcdefghijklmnoprstuqvwxyz".
    f_ENG  = f_ENG  + "ABCDEFGHIJKLMNOPRSTUQVWXYZ".
    f_ENG  = f_ENG  + "euiasgklzcn".
    f_ENG  = f_ENG  + "EUIASGKLZCN".
    f_ENG  = f_ENG  + "abvgdezzijklmnoprstufhccssjyjeua".
    f_ENG  = f_ENG  + "ABVGDEZZIJKLMNOPRSTUFHCCSSJYJEUA".
    
    DEF VAR c AS CHAR CASE-SENSITIVE NO-UNDO.
    DEF VAR i AS INT64 NO-UNDO.
    DEF VAR f AS INT64 NO-UNDO.
    DEF VAR s1 AS LONGCHAR NO-UNDO.
    DEF VAR s2 AS LONGCHAR NO-UNDO.
    
    DO i = 1 TO LENGTH(f_STR):
        C = SUBSTRING(f_STR, I, 1).
        f = index(f_KOI8, c).
        IF f > 0 THEN c = SUBSTRING(f_ENG, f, 1).
        S1 = SUBSTRING(f_STR, 1, I - 1).
        S2 = SUBSTRING(f_STR, I + 1).
        f_STR = S1 + C + S2.
    END.
    RETURN f_STR.
END.

DEF VAR STR_PDS AS DEC NO-UNDO.
DEF VAR STR_PTS AS DEC NO-UNDO.
DEF VAR STR_SSA AS INT64 NO-UNDO.
DEF VAR STR_SFA AS INT64 NO-UNDO.
DEF VAR STR_SFB AS INT64 NO-UNDO.

METHOD PRIVATE CHAR DETECT_CP_RU(f_Val AS LONGCHAR, f_Mode AS INT64):
    DEF VAR e_Val AS CHAR NO-UNDO.
    e_Val = f_Val.
    RETURN DETECT_CP_RU(e_Val, f_Mode).
END.


METHOD PRIVATE CHAR DETECT_CP_RU(f_Val AS CHAR, f_Mode AS INT64):
    /* пюяонгмюер псяяйсч йндхпнбйс KOI8<->1251  */
    /* f_Mode = 0 - Default                      */
    /* f_Mode = 1 - No extraanalize (saves time) */
    DEF VAR f_Cp    AS CHAR NO-UNDO CASE-SENSITIVE.
    DEF VAR f_Lat   AS CHAR CASE-SENSITIVE NO-UNDO . 
    f_Lat = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM".
    DEF VAR f_Gla   AS CHAR NO-UNDO INIT "йуеыаоэяиюьЙУЕЫАОЭЯИЮЬ" CASE-SENSITIVE.
    DEF VAR f_Sgl   AS CHAR NO-UNDO INIT "цкнгшщзхъфвпрлджчсмтбЦКНГШЩЗХЪФВПРЛДЖЧСМТБ" CASE-SENSITIVE.
    DEF VAR f_Ssg   AS CHAR NO-UNDO INIT "цшщхъфжчсЦШЩХЪФЖЧС" CASE-SENSITIVE.
    DEF VAR f_Szg   AS CHAR NO-UNDO INIT "кнгзвпрлдмтбКНГЗВПРЛДМТБ" CASE-SENSITIVE.
    DEF VAR f_Dig   AS CHAR NO-UNDO INIT "1234567890" CASE-SENSITIVE.
    DEF VAR f_Sgn   AS CHAR NO-UNDO INIT """'- ,;./\|:#!?=+_<>`~@#$%^&*()".
    
    /* Chashe vstrechajushiejsja bukvy russkogo jazyka (A-GRUPPA-53%) */
    DEF VAR f_Sfa   AS CHAR NO-UNDO INIT "оОеЕаАиИтТнНсСр" CASE-SENSITIVE.
    /* Chashe vstrechajushiejsja bukvy russkogo jazyka (B-GRUPPA-29%)*/
    DEF VAR f_Sfb   AS CHAR NO-UNDO INIT "РвВлЛкКмМдДпПуУ" CASE-SENSITIVE.
    /* Meneje vsrechajushiesja bukvi russkogo jazyka   (C-GRUPPA-19%)*/
    DEF VAR f_Ssa   AS CHAR NO-UNDO INIT "яЯыЫзЗьЬбБгГчЧйЙхХжЖюЮшШчЧщЩэЭфФ" CASE-SENSITIVE.
   
    DEF VAR f_Sfa_i AS INT64 NO-UNDO. /* Schetchik simvolov (A-GRUPPA-53%) */
    DEF VAR f_Sfb_i AS INT64 NO-UNDO. /* Schetchik simvolov (B-GRUPPA-29%) */
    DEF VAR f_Ssa_i AS INT64 NO-UNDO. /* Schetchik simvolov (C-GRUPPA-19%) */
    DEF VAR f_Gla_i AS INT64 NO-UNDO.
    DEF VAR f_Sgl_i AS INT64 NO-UNDO.
    DEF VAR f_Ssg_i AS INT64 NO-UNDO.
    DEF VAR f_Szg_i AS INT64 NO-UNDO.
    DEF VAR f_Lat_i AS INT64 NO-UNDO.
    DEF VAR f_Lng   AS iNT64 NO-UNDO.
    DEF VAR i       AS INT64 NO-UNDO. 
    DEF VAR s       AS CHAR  NO-UNDO CASE-SENSITIVE.
    DEF VAR f_SI    AS INT64 NO-UNDO.
    DEF VAR f_SII   AS INT64 NO-UNDO.
    DEF VAR f_GI    AS INT64 NO-UNDO.
    DEF VAR f_GII   AS INT64 NO-UNDO.
    DEF VAR f_DI    AS INT64 NO-UNDO.
    DEF VAR f_ZI    AS INT64 NO-UNDO.
    DEF VAR f_ZW    AS INT64 NO-UNDO.
    DEF VAR f_DT    AS INT64 NO-UNDO. 
    DEF VAR f_SP    AS INT64 NO-UNDO.
    DEF VAR f_S     AS INT64 NO-UNDO.
    DEF VAR f_G     AS INT64 NO-UNDO.
    DEF VAR f_Z     AS INT64 NO-UNDO.
    
    f_Val = f_Val + " ".
    f_Lng = LENGTH(f_Val).
    DO i = 1 TO f_Lng:
        s = SUBSTRING(f_Val, i, 1).
        IF index(f_Sfa, s) > 0 THEN f_Sfa_i = f_Sfa_i + 1.
        IF index(f_Sfb, s) > 0 THEN f_Sfa_i = f_Sfb_i + 1.
        IF index(f_Ssa, s) > 0 THEN f_Ssa_i = f_Ssa_i + 1.
        
        IF index(f_Lat, s) > 0 THEN
         DO:
            f_Lat_i = f_Lat_i + 1.
            f_Z  = 0.
            f_G  = 0.
            f_S  = 0.
         END.
        ELSE IF index(f_Dig, s) > 0 THEN
         DO:
            f_DI = f_DI + 1.
            f_Z  = 0.
            f_G  = 0.
            f_S  = 0.
         END.
        ELSE IF index(f_Sgn, s) > 0 THEN
         DO:
            IF s = "." THEN f_DT = f_DT + 1.
            IF s = " " THEN f_SP = f_SP + 1.
            IF f_Z = 0 THEN f_ZW = f_ZW + 1.
            f_Z  = f_Z + 1.
            f_ZI = f_ZI + 1.
            f_G  = 0.
            f_S  = 0.
         END.
        ELSE IF index(f_Gla, s) > 0 THEN 
         DO:
            f_Gla_i = f_Gla_i + 1.
            f_G     = f_G     + 1.
            f_S     = 0.
            f_Z     = 0.
            IF f_G > 2 THEN f_GI = f_GI + 1.
            IF f_G > 3 THEN f_GII = f_GII + 1.
         END.
        ELSE IF index(f_Sgl, s) > 0 THEN 
         DO:
            f_Sgl_i = f_Sgl_i + 1.
            f_S     = f_S     + 1.
            f_G     = 0.
            f_Z     = 0.
            IF f_S > 2 THEN f_SI  = f_SI + 1.
            IF f_S > 3 THEN f_SII = f_SII + 1.
            IF index(f_Ssg, s) > 0 THEN f_Ssg_i = f_Ssg_i + 1.
            IF index(f_Szg, s) > 0 THEN f_Szg_i = f_Szg_i + 1.
         END.
    END.
    
    /*IF SYS_CP_DEBUG_INFO <> 0 THEN*/
      /*
      disp f_Lng " " f_Lat_i " " f_Gla_i " "  f_Sgl_i " "  f_Ssg_i " " 
           f_Szg_i " " f_SI " " f_GI " " f_ZW " " f_ZI " " f_DI.
         */
    DEF VAR pg  AS DEC NO-UNDO.
    DEF VAR ps  AS DEC NO-UNDO.
    DEF VAR pds AS DEC NO-UNDO. /* PROCENT DVOINYH SOGLASNIH */
    DEF VAR pts AS DEC NO-UNDO. /* PROCENT TROJNIH SOGLASNIH */
    DEF VAR pdg AS DEC NO-UNDO. /* PROCENT DVOINYH GLASNIH   */
    DEF VAR ptg AS DEC NO-UNDO. /* PROCENT TROJNIH GLASNIH   */
    
    DEF VAR f_RUS AS INT64 NO-UNDO.
    f_RUS = (f_Lng - f_Lat_i - f_Zi - f_Di).
    pds = f_SI    / f_ZW.
    pts = f_SII   / f_ZW.
    pdg = f_GI    / f_ZW.
    ptg = f_GII   / f_ZW.
    pg  = f_Gla_i / f_Rus.
    ps  = f_Sgl_i / f_Rus.
    STR_PDS = pds.
    STR_PTS = pts.
    STR_SSA = f_Ssa_i. /* Rezhe vstrechajushiesja simvoli  (C)*/
    STR_SFA = f_Sfa_i. /* Chasto vstrechajushiesja simvoli (A)*/
    STR_SFB = f_Sfb_i. /* Chasto vstrechajushiesja simvoli (B)*/
/*    
    MESSAGE f_Sfb_i " " f_Sfa_i " " f_Ssa_i VIEW-AS ALERT-BOX.
*/    
/*   
    MESSAGE f_ZI " " f_GI " " pg " " f_Gla_i / f_ZW " " ps 
            " " f_Sgl_i / f_ZW " " 
            pdg " " ptg " " pds " " pts " " f_ZW  VIEW-AS ALERT-BOX. 
*/    
    IF f_Lat_i + f_ZI + f_DI = f_Lng THEN 
        f_CP = "1252". /* KOI8-RL */
    ELSE IF /*pds < 0.27 AND pts < 0.1 and pdg < 0.10 
        AND ((f_ZI - f_SP) < f_ZW * 0.4) 
        OR*/ STR_SSA <= STR_SFA * 0.35        /* 0.2 */
        AND  STR_SFB <= STR_SFA * 0.55 THEN
     DO:
        f_CP = "KOI8-RL".
     END.
    ELSE IF (f_GI = 0 AND (   f_SI = 0 
                           OR f_SI = 1 AND f_ZW = 1 AND f_Ssg_i <> f_Szg_i))
                           
        AND (
             (pg > 0.3 AND pg < 0.4 ) AND (ps > 0.6 AND ps < 0.7 )
              AND
             (pds < 0.30 AND pts < 0.1)
            )
        AND  STR_SSA <= STR_SFA * 0.6  /* 0.4 */
        THEN f_CP = "KOI8-RL".
    ELSE IF ((f_SI + f_GI - f_DT) >= f_ZW / 2 AND NOT (f_SI = 1 AND f_ZW = 1) ) 
         OR f_GI > 0 THEN f_CP = "1251".
    ELSE DO:
        IF f_Mode = 0 THEN
         DO:
          IF DETECT_CP_RU(SYS_CONVERT_STR(f_Val,"","1251"), 1) = "KOI8-RL"
           THEN f_CP = "1251". 
           /* оПНЦПЮЛЛЮ МЕ ЛНФЕР НОПЕДЕКХРЭ ЙНДХПНБЙС МЮ АЮГЕ ЯРЮРХЯРХЙХ */
          ELSE  
           DO: 
            IF pds <= STR_PDS AND pts <= STR_PTS OR 
                (      STR_SSA <= STR_SFA * 0.35
                  AND  STR_SFB <= STR_SFA * 0.55  )
               /*(STR_SSA <= STR_SFA * 0.2)*/ THEN
                f_CP = "KOI8-RL".
            ELSE
                f_CP = "1251".
           END.
         END.
        ELSE
            f_CP = /*"1251".*/ "KOI8-RL".
    END.
    STR_PDS = pds.
    STR_PTS = pts.
    RETURN f_CP.
END.

/* пЮЯОНГМЮЕР ЙНДХПНБЙС МЮ АЮГЕ БУНДМНЦН РЕЙЯРЮ */
METHOD PRIVATE CHAR DETECT_CP(f_Str AS LONGCHAR):
    DEF VAR e_Str AS CHAR NO-UNDO.
    e_Str = f_Str.
    RETURN DETECT_CP(e_Str).
END.

METHOD PRIVATE CHAR DETECT_CP(f_Str AS CHAR):
    DEF VAR c     AS CHAR NO-UNDO.
    DEF VAR c_1   AS CHAR NO-UNDO.
    DEF VAR c_2   AS CHAR NO-UNDO.
    DEF VAR en_cp AS INT64  NO-UNDO.
    DEF VAR ne_cp AS INT64  NO-UNDO.
    DEF VAR al_cp AS INT64  NO-UNDO.
    DEF VAR dg_cp AS INT64  NO-UNDO.
    DEF VAR r_CP  AS CHAR NO-UNDO.
    DEF VAR nf_cp AS INT64  NO-UNDO.
    DEF VAR f_S1257   AS CHAR NO-UNDO INIT "ГШНБПЛМОЧХРгшнбплмочхр".
    DEF VAR f_SKOI9RL AS CHAR NO-UNDO INIT "ēūīāšģķļžčņĒŪĪĀŠĢĶĻŽČŅ".
    DEF VAR i_S1257   AS INT64  NO-UNDO.
    DEF VAR i_SKOI9RL AS INT64  NO-UNDO.
    DEF VAR i         AS INT64  NO-UNDO.
    nf_cp = 0.
    
    al_cp = LENGTH(f_Str).
    DO i = 1 TO al_cp:
        c_2 = c_1.
        c_1 = c.
        c = SUBSTRING(f_Str, i, 1).
        
        IF ASC(c) < 128 THEN 
         DO:
            IF ASC(c) > ASC('9') THEN 
                en_cp = en_cp + 1.
            ELSE
                dg_cp = dg_cp + 1.
         END.
        ELSE
         DO:
            IF index(f_S1257,   c) > 0 THEN i_S1257   = i_S1257   + 1.
            IF index(f_SKOI9RL, c) > 0 THEN i_SKOI9RL = i_SKOI9RL + 1.
            IF ASC(c_1) > 128 AND ASC(c_2) > 128 THEN nf_cp = 1.
            ne_cp = ne_cp + 1.
         END.
    END.
    IF al_cp = en_cp + dg_cp THEN r_CP = "".
    ELSE IF int64(en_cp / (al_cp - dg_cp) * 100) > 65 
       AND nf_cp = 0 THEN 
        DO:
            IF i_S1257 > i_SKOI9RL THEN
                r_CP = "1257".
            ELSE
                r_CP = "KOI8-RL".
        END.
    ELSE 
     DO:
          r_CP = DETECT_CP_RU(f_Str, 0).
          /*r_CP = "1251".*/
     END.
    RETURN r_CP.
END.

/***********************************************************************/
/***********************************************************************/
/** THIS FUNCTION IS UNIVERSAL STRING CONVERTER                       **/
/** f_To_CP:   KOI8RL, UTF-8, 1251, 1257, 1250, 1252, UHTM, ENG       **/
/** f_From_Cp: auto, KOI8RL, UTF-8, 1251, 1257, 1250, 1252, UHTM      **/
/** auto - Autodect of source encoding (1251, KOI8RL, 1257);          **/
/** UHTM - ASCII UNICODE ENCODING (all non english symbols are        **/
/**        converted like &#9999;)                                    **/
/**        where 9999 - integer code of unicode character             **/
/** ENG  - Tranluteration of all non english symbols                  **/
/**        (all english symbols are converted into corresponding      **/
/**        english symbols                                            **/
/***********************************************************************/
/***********************************************************************/

/* sys_convert_str_LONGCHAR Выдернул из sysodf */
METHOD PRIVATE LONGCHAR sys_convert_str_LONGCHAR(convert_str as LONGCHAR,
            f_To_CP AS CHAR,
            f_From_Cp AS CHAR):
    DEF VAR convert_str_part as CHAR NO-UNDO.
    DEF VAR return_convert_str as LONGCHAR NO-UNDO.
    DEF VAR iii as INT NO-UNDO.
    DEF VAR Size as INT NO-UNDO.
    Size = 1000. /*на какую длину делим LONGCHAR строку*/
    iii = 1.
    do while iii le length (convert_str):
        /*последовательно делим LONGCHAR строку, конвертируем CHAR кусочки и собираем обратно в LONGCHAR*/
        convert_str_part = substring(convert_str, iii, Size).
        convert_str_part = sys_convert_str(convert_str_part, f_To_CP, f_From_Cp).
        return_convert_str = return_convert_str + convert_str_part.
        iii = iii + Size.
    end.
    RETURN return_convert_str.
END.

METHOD PRIVATE LONGCHAR sys_convert_str(f_Str AS LONGCHAR, f_To_CP AS CHAR):
    RETURN sys_convert_str(f_Str, f_To_CP, "").
END.


METHOD PRIVATE LONGCHAR sys_convert_str(  f_Str AS LONGCHAR, 
                                   f_To_CP AS CHAR, 
                                 f_From_Cp AS CHAR):
    DEF VAR e_Str AS CHAR NO-UNDO.
    DEF VAR e_Val AS LONGCHAR NO-UNDO.
    
    e_Val = sys_convert_str_LONGCHAR(f_Str, f_To_CP, f_From_Cp).
    /*IF LENGTH(e_Val, "RAW") > 31991 THEN*/ RETURN e_Val.
    /*
    e_Str = f_Str.
    e_Val = sys_convert_str(e_Str, f_To_CP, f_From_Cp).
    RETURN e_Val.
    */
END.

METHOD PRIVATE CHAR sys_convert_str( f_Str AS CHAR, 
                                  f_To_CP AS CHAR, 
                                f_From_Cp AS CHAR):
    IF lc(trim(f_From_Cp)) = "auto" THEN 
     DO:
        f_From_Cp = DETECT_CP(SUBSTRING(f_Str,1,250)).
     END.
    IF f_From_Cp = "" THEN f_From_Cp = SESSION:CHARSET.
    IF f_To_CP = ""   THEN f_To_CP   = SESSION:CHARSET.
     
    IF INDEX(f_Str, "&#") > 0 THEN
     DO:
        IF f_From_Cp <> "" AND f_From_Cp <> SESSION:CHARSET THEN
         DO:
            f_Str = CODEPAGE-CONVERT(f_Str, SESSION:CHARSET, f_From_Cp).
         END.
         IF f_To_CP = "UHTM" THEN
             f_Str = UHTM_TO_UTF8(f_Str, 1).
         ELSE
             f_Str = UHTM_TO_UTF8(f_Str, 0).
                                          
         f_Str = CODEPAGE-CONVERT(f_Str, SESSION:CHARSET, "UTF-8").
         IF f_To_CP <> SESSION:CHARSET THEN
          DO:
            IF f_To_CP = "UHTM" THEN
             DO:
                f_Str = CODEPAGE-CONVERT(f_Str, "UTF-8").
                f_Str = UTF8_TO_UHTM(f_Str, false).
             END.
            ELSE IF f_To_CP = "ENG" THEN
             DO:
                f_Str = KOI8_TO_ENG(f_Str).
             END.
            ELSE
             f_Str = CODEPAGE-CONVERT(f_Str, f_To_Cp, SESSION:CHARSET).
          END.
     END.
    ELSE
     DO:
            IF f_From_Cp = "UHEX" THEN
             DO:
                f_From_Cp = "UTF-8".
                f_Str = UHEX_TO_UTF8(f_Str).
             END.
            ELSE
             DO:
                IF f_To_CP = "UHTM" OR f_To_CP = "UHEX" THEN
                 DO:
                    f_Str =  CODEPAGE-CONVERT(f_Str, "UTF-8", f_From_Cp).
                 END.
             END.
             
            IF f_To_CP = "UHTM" THEN
             DO:
                f_Str = UTF8_TO_UHTM(f_Str, false).
             END.
            ELSE IF f_To_CP = "ENG" THEN
             DO:
                f_Str = KOI8_TO_ENG(f_Str).
             END.
            ELSE IF f_To_CP = "UHEX" THEN
             DO:
                f_Str = UTF8_TO_UHTM(f_Str, true).
             END.
            ELSE
             DO:
                f_Str =  CODEPAGE-CONVERT(f_Str, f_To_Cp, f_From_Cp).
             END.
     END.
    RETURN f_Str.
END.


METHOD PRIVATE CHAR UCHR_TO_UTF8(f_Asc AS INT64):
    DEF VAR r_Str as char NO-UNDO.
    DEF VAR bt1 as int64 NO-UNDO.
    DEF VAR bt2 as int64 NO-UNDO.
    DEF VAR bt3 as int64 NO-UNDO.

    DEF VAR sv as int64 NO-UNDO.
    DEF VAR ss as int64 NO-UNDO.
    DEF VAR r1 as int64 NO-UNDO.
    DEF VAR r2 as int64 NO-UNDO.
    DEF VAR r3 as int64 NO-UNDO.
    DEF VAR r4 as int64 NO-UNDO.
    sv = f_Asc.

    bt3 = sv mod 256.
    ss  = ((sv - bt3) / 256).
    bt2 = ss mod 256.
    bt1 = ((ss - bt2) / 256) mod 256.
    /*disp bt1 bt2 bt3.*/
    IF bt1 = 0 and bt2 = 0 THEN
     DO:
        RETURN CHR(bt3).
     END.
    ELSE IF bt1 = 0 AND bt2 < 8 THEN
     DO:
        r1 = 192 + bt2 * 4 + (bt3 - (bt3 mod 64)) / 64.
        r2 = 128 + (bt3 mod 64).
        r3 = 0.
        r4 = 0.
        /*DISP r1 r2  bt2 * 4 .*/
     END.
    ELSE IF bt1 = 0 AND bt2 > 31 THEN
     DO:
        r1 = 224 + (bt2 - (bt2 mod 16)) / 16.
        r2 = 128 + (bt2 mod 16) * 4 + (bt3 - (bt3 mod 64)) / 64.
        r3 = 128 + (bt3 mod 64).
        r4 = 0.
     END.
    RETURN CHR(r1) + CHR(r2) + CHR(r3) + CHR(r4).
END.

METHOD PRIVATE LONGCHAR UHTM_TO_UTF8 (f_Str     AS LONGCHAR ):
    DEF VAR e_Str AS CHAR NO-UNDO.
    DEF VAR e_Val AS LONGCHAR     NO-UNDO.
    e_Str = f_Str.
    e_Val = UHTM_TO_UTF8(e_Str).
    RETURN e_Val.
END.

METHOD PRIVATE CHAR UHTM_TO_UTF8 (f_Str     AS CHAR ):
    RETURN UHTM_TO_UTF8(f_Str, 0).
END.

METHOD PRIVATE CHAR UHTM_TO_UTF8 (f_Str     AS CHAR, f_Mode AS INT64):
    DEF VAR c     AS INT64 NO-UNDO.
    DEF VAR ce    AS INT64 NO-UNDO.
    DEF VAR r_Str AS CHAR NO-UNDO.
    DEF VAR f_S   AS char NO-UNDO.
    DEF VAR f_Chr AS CHAR  NO-UNDO.
    IF f_Mode = 2 THEN RETURN UHEX_TO_UTF8(f_Str).
    
    f_Str = CODEPAGE-CONVERT(f_Str, "UTF-8") .
    c = 0.
    DO WHILE c <> 1:
        IF c = 0 THEN c = 1.
        C = INDEX(f_Str, "&#", C).
        IF c = 0 THEN LEAVE.
        ce = INDEX(f_Str, ";", C + 1).
        /*disp c ce.*/
        /*pause.*/
        IF ce - c < 9 AND ce - c > 2 THEN
         DO:
            f_Chr = SUBSTRING(f_Str, c + 2, ce - c - 2).
            f_Chr = Replace(f_Chr, " ", "").
            IF f_Mode = 0 THEN
                f_s = UCHR_TO_UTF8(INT(f_Chr)).
            ELSE
                f_s = "&#" + f_Chr + ";".
            IF f_s = ? or f_s = "?" THEN f_s = "&#" + f_Chr + ";".
            f_Str = SUBSTRING(f_Str, 1, c - 1) + f_s + SUBSTRING(f_Str, ce + 1).
         END.
        C = C + 1.
    END.
    RETURN f_Str.
END.

/* Преобразует последовательность типа [\041F\0440\0438] или [\u041F\u0440\u0438] в UTF-8 */
METHOD PRIVATE CHAR UHEX_TO_UTF8 (iStr AS CHAR):
    RETURN UHEX_TO_UTF8(iStr, FALSE).
END.

METHOD PRIVATE CHAR UHEX_TO_UTF8 (iStr AS CHAR, iWebMode AS LOG):
    DEFINE VARIABLE tStr AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE oStr AS CHAR     NO-UNDO.
    tStr = iStr.
    tStr = UHEX_TO_UTF8(tStr, iWebMode).
    oStr = STRING(tStr).
    RETURN oStr.
END.

METHOD PRIVATE LONGCHAR UHEX_TO_UTF8 (iStr AS LONGCHAR, iWebMode AS LOG):
    DEF VAR cb         AS INT64 NO-UNDO.
    DEF VAR decodedChr AS CHAR  NO-UNDO.
    DEF VAR tHexCode   AS CHAR  NO-UNDO.
    DEF VAR tPrefix    AS CHAR  NO-UNDO INIT "\\".
    DEF VAR tPrefixLen AS INT   NO-UNDO INIT 1.

    IF iWebMode THEN DO: tPrefix = '\\u'. tPrefixLen = 2. END.
    
    iStr = CODEPAGE-CONVERT(iStr, "UTF-8").
    cb = 1.
    DO WHILE cb > 0:
        cb = INDEX(iStr, tPrefix, cb).
        IF cb = 0 THEN LEAVE.
        
        tHexCode = SUBSTRING(iStr, cb + tPrefixLen, 4).
        tHexCode = REPLACE(tHexCode, " ", "").
        decodedChr = UCHR_TO_UTF8(HexToInt(tHexCode)).
        IF decodedChr = ? or decodedChr = "?" THEN decodedChr = tPrefix + tHexCode + "".
        iStr = SUBSTRING(iStr, 1, cb - 1) + decodedChr + SUBSTRING(iStr, cb + 4 + tPrefixLen).
        cb = cb + 1.
    END.

    RETURN iStr.
END.

METHOD PRIVATE CHAR UHEX_TO_CHAR (pStr AS CHAR, iWebMode AS LOG):
   RETURN sys_convert_str(UHEX_TO_UTF8(pStr, iWebMode), "", "UTF-8").
END. 

METHOD PRIVATE CHAR UHEX_TO_CHAR (pStr AS CHAR):
   RETURN sys_convert_str(UHEX_TO_UTF8(pStr, FALSE), "", "UTF-8").
END. 

METHOD PRIVATE LONGCHAR UHEX_TO_CHAR (pStr AS LONGCHAR):
   RETURN sys_convert_str(UHEX_TO_UTF8(pStr, FALSE), "", "UTF-8").
END. 

METHOD PRIVATE LONGCHAR UHEX_TO_CHAR (pStr AS LONGCHAR, iWebMode AS LOG):
   RETURN sys_convert_str(UHEX_TO_UTF8(pStr, iWebMode), "", "UTF-8").
END. 

METHOD PRIVATE LONGCHAR UTF8_TO_UHTM (f_Str AS LONGCHAR):
    DEF VAR e_Str AS CHAR NO-UNDO.
    DEF VAR e_Val AS LONGCHAR     NO-UNDO.
    e_Str = f_Str.
    e_Val = UTF8_TO_UHTM (e_Str, false).
    RETURN e_Val.
END.


METHOD PRIVATE INT ASCL(f_Str AS LONGCHAR):
    DEF VAR e_Str AS CHAR NO-UNDO.
    e_Str = f_Str.
    RETURN ASC(e_Str).
END.


METHOD PRIVATE INT ASCL(f_Str AS CHAR):
    RETURN ASC(f_Str).
END.




METHOD PRIVATE CHAR UTF8_TO_UHTM (f_Str AS CHAR):
    RETURN UTF8_TO_UHTM (f_Str, False).
END.

METHOD PRIVATE CHAR UTF8_TO_UHTM (f_Str AS CHAR, f_Oracle_Mode AS LOG):
    DEF VAR i     AS INT64 NO-UNDO.
    DEF VAR r_Str AS CHAR  NO-UNDO.
    DEF VAR r1    as int64 NO-UNDO.
    DEF VAR r2    as int64 NO-UNDO.
    DEF VAR r3    as int64 NO-UNDO.
    DEF VAR r4    as int64 NO-UNDO.
    DEF VAR c     as char  NO-UNDO.
    DEF VAR a1    as int64 NO-UNDO.
    DEF VAR bt1   as int64 NO-UNDO.
    DEF VAR bt2   as int64 NO-UNDO.
    DEF VAR bt3   as int64 NO-UNDO.
    IF NOT f_Oracle_Mode THEN
     DO:
        f_Str = Replace(f_Str, "&", "&#38;").
        f_Str = Replace(f_Str, "&#38;nbsp;", "&nbsp;").
     END.

    DO i = 1 TO LENGTH(f_Str):
        c = SUBSTRING(f_Str, i, 1).
        a1 = asc(c).
        r1 = 0. r2 = 0. r3 = 0. r4 = 0.
        IF a1 < 128 THEN 
         DO:
            r1 = a1.
         END.
        ELSE IF a1 < 224 THEN
         DO:
            r1 = asc(c).
            r2 = ASCL(SUBSTRING(f_Str, i + 1, 1)) NO-ERROR.
            i = i + 1.
         END.
        ELSE IF a1 < 240 THEN
         DO:
            r1 = asc(c).
            r2 = ASCL(SUBSTRING(f_Str, i + 1, 1)) NO-ERROR.
            r3 = ASCL(SUBSTRING(f_Str, i + 2, 1)) NO-ERROR.
            i = i + 2.
         END.
        ELSE IF a1 < 248 THEN
         DO:
            r1 = asc(c).
            r2 = ASCL(SUBSTRING(f_Str, i + 1, 1)) NO-ERROR.
            r3 = ASCL(SUBSTRING(f_Str, i + 2, 1)) NO-ERROR.
            r4 = ASCL(SUBSTRING(f_Str, i + 3, 1)) NO-ERROR.
            i = i + 3.
         END.
        /**** ****/
        DEF VAR yyyyy as int64 NO-UNDO.
        IF r4 = 0 AND r3 = 0 AND r2 = 0 THEN 
         DO:
            r_Str = r_Str + CHR(r1).
         END.
        ELSE IF r4 = 0 AND r3 = 0 THEN
         DO:
            yyyyy = r1 mod 32.
            bt2 =  (yyyyy - (yyyyy mod 4)) / 4.
            bt1 = (yyyyy mod 4) * 64 + r2 mod 64.
            IF f_Oracle_Mode THEN
                r_Str = r_Str + "\\" + TO_HEX_E(bt2 * 256 + bt1, 4, 16).
            ELSE
                r_Str = r_Str + "&#" + STRING(bt2 * 256 + bt1) + ";".
            
         END.
        
    END.
    IF NOT f_Oracle_Mode THEN r_Str = Replace(r_Str, "&#38;#", "&#").
    RETURN r_Str.
END.

/*** Проверка правильности ввода цислового значения в качестве строки ***/
METHOD PRIVATE INT64 CHK_NUMBER (f_Num AS CHAR, f_DEC AS CHAR, 
                         f_Min AS CHAR, f_MAX AS CHAR):
    /*
        f_Num - число в виде строки.
        f_DEC - количество позиций после запятой 
                (если указан знак = , то проверяется на точное совподение).
        f_Min - минимальное значение.
        f_MAX - максимальное значение.
        
        RETURN - возвращаемое значение: если RETURN < 0 то цисло не
                 соответствует указанным параметрам.
    */                         
                         
    DEF VAR f_Val     AS DEC NO-UNDO.
    DEF VAR f_Val_Min AS DEC NO-UNDO.
    DEF VAR f_Val_Max AS DEC NO-UNDO.
    DEF VAR f_Val_Dec AS DEC NO-UNDO.
    
    f_Num = TRIM(f_Num).
    f_Val = DEC(f_Num) NO-ERROR.
    IF f_Min <> "" THEN
     DO:
        f_Val_Min = DEC(f_MIN) NO-ERROR.
        IF f_Val_Min > f_Val THEN RETURN -1.
     END.
    IF f_Max <> "" THEN
     DO:
        f_Val_Max = DEC(f_MAX) NO-ERROR.
        IF f_Val_Max < f_Val THEN RETURN -2.
     END.
    DEF VAR c   AS INT64  NO-UNDO.
    DEF VAR i   AS INT64  NO-UNDO.
    DEF VAR s   AS CHAR   NO-UNDO.
    DEF VAR fln AS INT64  NO-UNDO.
    DEF VAR fsg AS INT64  NO-UNDO.
    DEF VAR fdt AS INT64  NO-UNDO.
    DEF VAR fff AS CHAR   NO-UNDO.
    fln = LENGTH(f_Num).
    DO i = 1 TO fln:
        s = SUBSTRING(f_Num, i, 1).
        IF s = "-" THEN 
         DO:
            fsg = fsg + 1.
            IF fsg > 1 THEN RETURN -8.
            IF i <> 1 AND i <> fln THEN RETURN -9.
         END.
        IF s = "." THEN 
         DO:
            fdt = fdt + 1.
            IF fsg > 1 THEN RETURN -10.
         END.
        IF INDEX("-0123456789.", s) <= 0 THEN RETURN -5.
        IF INDEX(" ,",s) <= 0 THEN fff = fff + s.
    END.
    f_Num = fff.
    c = INDEX(f_Num, ".").
    IF c > 0 AND INDEX(f_Num, ".", c + 1) > 0 THEN RETURN -3.
    IF fln = c THEN RETURN -4.
    IF c > 0 AND f_Dec = "" THEN f_Dec = STRING(fln - c).
    IF f_DEC <> "" THEN
     DO:
        DEF VAR f_s AS CHAR NO-UNDO.
        f_s = SUBSTRING(f_Dec,1,1).
        IF f_s = "=" THEN 
         f_DEC = SUBSTRING(f_Dec,2,1).
        ELSE f_S = "".
        
        f_VAL_DEC = DEC(f_DEC) NO-ERROR.
        IF c > 0 THEN
         DO:
            IF      NOT (fln - c <= f_VAL_DEC AND f_s <> "=") 
                AND NOT (fln - c  = f_VAL_DEC AND f_s =  "=")
                THEN
             DO:
                RETURN -6.
             END.
         END.
        ELSE IF f_DEC <> "" AND f_Val_DEC > 0 AND f_s = "=" THEN RETURN -7.
        
     END.
    
    RETURN 0.
END.

METHOD PRIVATE INT64 IS_NUMBER (f_Num AS CHAR):
    RETURN CHK_NUMBER(f_Num, "", "", "").
END.

METHOD PRIVATE CHAR KOI8_TO_UHTM (f_Str AS CHAR):
    RETURN KOI8_TO_UHTM (f_Str, false).
END.

METHOD PRIVATE CHAR KOI8_TO_UHTM (f_Str AS CHAR, f_Oracle_Mode AS LOG):
    f_Str = sys_convert_str(f_Str, "UTF-8", "").
    RETURN UTF8_TO_UHTM(f_Str, f_Oracle_Mode).
END.

/**************************************************************************/
/*** REMOVES HTML TAGS FROM TEKST                                       ***/
/**************************************************************************/
METHOD PRIVATE CHAR STR_RemoveTags (f_Str AS CHAR):
    DEF VAR c1 AS INT64 NO-UNDO.
    DEF VAR c2 AS INT64 NO-UNDO.
    DEF VAR c3 AS INT64 NO-UNDO.
    c1 = Index(f_Str, "<", c2 + 1).
    c2 = Index(f_Str, ">", c1 + 1).
    c3 = Index(f_Str, "<", c1 + 1).
    DO WHILE c1 > 0:
        IF c2 > c3 and c3 > 0 THEN
         DO:
            c1 = c3.
         END.
        ELSE IF c1 > 0 and c2 > 0 THEN
          DO:
                f_Str = SUBSTRING(f_Str, 1, c1 - 1) + SUBSTRING(f_Str, c2 + 1).
                c2 = c1 - 1.
          END.
        c1 = Index(f_Str, "<", c2 + 1).
        c2 = Index(f_Str, ">", c1 + 1).
        c3 = Index(f_Str, "<", c1 + 1).
    END.
   RETURN f_Str.
END.

/* Целая часть от дробного числа */
METHOD PRIVATE INT64 GET_INT(f_Dec AS DEC):
    DEF VAR dd as dec   NO-UNDO.
    DEF VAR di AS INT64 NO-UNDO.
    di = int64(f_Dec).
    IF di > f_Dec then di = di - 1.
    RETURN di.
END.

/* Текстовая строка с текушей датой и временем  */
METHOD PRIVATE CHAR TMS():
    RETURN FormatDateTime(today, time, 0, "dd.mm.yyyy hh:mm:ss").
END.

/*message index(B64STR, "/") - 1.*/
METHOD PRIVATE CHAR IND_TO_B64(f_Ind AS INT):
    DEF VAR Val AS CHAR.
    IF f_Ind >= 0 AND f_Ind < 65 THEN RETURN SUBSTRING(B64STR, f_Ind + 1, 1).
    RETURN "".
END.

METHOD PRIVATE CHAR STR_TO_B64(f_Str AS CHAR):
    DEF VAR Vl AS LONGCHAR NO-UNDO.
    Vl = f_Str.
    f_Str = STR_TO_B64(Vl).
    RETURN f_Str.
END.

METHOD PRIVATE LONGCHAR STR_TO_B64(f_Str AS LONGCHAR):
    DEF VAR MSTR AS MEMPTR NO-UNDO.
    DEF VAR Ln   AS INT NO-UNDO.
    Ln = LENGTH(f_Str).
    SET-SIZE(MSTR) = 0.
    SET-SIZE(MSTR) =  Ln + 1.
    COPY-LOB f_Str TO MSTR.
    f_Str = STR_TO_B64(MSTR, Ln).
    SET-SIZE(MSTR) = 0.
    RETURN f_Str.
END.

METHOD PRIVATE LONGCHAR STR_TO_B64(MSTR AS MEMPTR, Ln   AS INT):
    DEF VAR Val AS LONGCHAR NO-UNDO.
    Val = BASE64-ENCODE(MSTR).
    SET-SIZE(MSTR) = 0.
    RETURN Val.
END.

METHOD PRIVATE CHAR STR_TO_MIMEUTFB64(f_Str AS CHAR, LIMIT75 AS INT):
     DEF VAR Vl AS LONGCHAR NO-UNDO.
     Vl = f_Str.
     f_Str = STR_TO_MIMEUTFB64(Vl, LIMIT75).
     RETURN f_Str.
END.

/*LIMIT75: 0-Ignore; 1-MIME75; 2-75 */
METHOD PRIVATE LONGCHAR STR_TO_MIMEUTFB64(f_Str AS LONGCHAR, LIMIT75 AS INT):
    DEF VAR Val AS LONGCHAR NO-UNDO.
    DEF VAR Ln  AS INT      NO-UNDO.
    Val = STR_TO_B64(sys_convert_str(f_Str, "UTF-8", "")).

    IF Val = ? THEN Val = "".
    IF LIMIT75 < 2 THEN Val = "=?utf-8?b?" + Val + "?=".
    Ln = LENGTH(Val).
    
    IF Ln > 75 AND LIMIT75 = 1 THEN
     DO:
        DEF VAR i AS INT      NO-UNDO.
        DEF VAR r AS LONGCHAR NO-UNDO.
        DO i = 1 TO Ln:
            r = r + SUBSTRING(Val, i, 75) + CHR(13) + CHR(10) + "".
        END.
        RETURN r.
     END.
     
    RETURN Val.
END.

/*LIMIT75: 0-Ignore; 1-MIME75; 2-75 */
METHOD PRIVATE LONGCHAR STR_TO_MIMEUTFB64(MSTR AS MEMPTR, Ln   AS INT, LIMIT75 AS INT):
    DEF VAR Val AS LONGCHAR NO-UNDO.
    /*    Val = STR_TO_B64(MSTR, Ln).   */
    Val = BASE64-ENCODE(MSTR).
    IF Ln > 75 AND LIMIT75 = 1 THEN
     DO:
        DEF VAR i AS INT      NO-UNDO.
        DEF VAR r AS LONGCHAR NO-UNDO.
        i = 1.
        DO WHILE i < Ln:
            r = r + SUBSTRING(Val, i, 75) + CHR(13) + CHR(10) + "".
            i = i + 75.
        END.
        RETURN r.
     END.
    RETURN Val.
END.

METHOD PRIVATE LONGCHAR FILE_TO_B64(FileName AS CHAR):
    DEF VAR MSTR AS MEMPTR NO-UNDO.
    DEF VAR Ln   AS INT    NO-UNDO.
    
    file-info:file-name = FileName.
    Ln = file-info:file-size. 
    DEF VAR Val AS LONGCHAR NO-UNDO.
    IF SEARCH(FileName) <> ? THEN
     DO:
        COPY-LOB FROM FILE FileName TO MSTR.
        Val = STR_TO_MIMEUTFB64(MSTR, Ln, 2).
     END.
    ELSE
     DO:
        MESSAGE "(stringApi.cls:FILE_TO_B64) Document " + FileName + " not exists!" VIEW-AS ALERT-BOX.
     END.
    RETURN Val.
END.

METHOD PRIVATE CHAR ORA_FIELD (pStr AS CHAR):
    pStr = REPLACE(pStr, "'", "\\0027").
    RETURN "UNISTR('" + KOI8_TO_UHTM(pStr, true) + "')".
END.

METHOD PRIVATE CHAR ORA_FIELD (pStr AS LONGCHAR):
    pStr = REPLACE(pStr, "'", "\\0027").
    RETURN "UNISTR('" + KOI8_TO_UHTM(STRING(pStr), true) + "')".
END.

METHOD PRIVATE CHAR ORA_FIELD (pVal AS INT):
    RETURN "'" + STRING(pVal) + "'".
END.

METHOD PRIVATE CHAR ORA_FIELD (pVal AS DEC):
    RETURN "'" + STRING(pVal) + "'".
END.

METHOD PRIVATE CHAR ORA_FIELD (pVal AS INT64):
    RETURN "'" + STRING(pVal) + "'".
END.

METHOD PRIVATE CHAR ORA_FIELD (pVal AS DATE):
    RETURN "TO_DATE(" + CFormat(pVal, "'yyyy/mm/dd 00:00:00'") + ", 'yyyy/mm/dd hh24:mi:ss')".
END.
METHOD PRIVATE CHAR ORA_FIELD (pDate AS DATE, pTime AS INT):
    RETURN "TO_DATE(" + CFormat(pDate, pTime, "'yyyy/mm/dd hh:mm:ss'") + ", 'yyyy/mm/dd hh24:mi:ss')".
END.

   
METHOD PRIVATE CHAR ORA_FIELD (pVal AS DATETIME):
    RETURN "TO_DATE(" + CFormat(pVal, "'yyyy/mm/dd hh:mm:ss'") + ", 'yyyy/mm/dd hh24:mi:ss')".
END.



METHOD PRIVATE INTEGER HexToInt (INPUT chHEX AS CHARACTER):
    DEFINE VARIABLE ININTEGER   AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE inj         AS INTEGER NO-UNDO.
      
    chHEX = CAPS(chHEX).
    DO inj = 1 TO LENGTH(chHEX):
        IF CAN-DO("0,1,2,3,4,5,6,7,8,9", (SUBSTRING(chHEX, inj, 1))) THEN
            ININTEGER = ININTEGER 
                  + INT(SUBSTRING(chHEX, inj, 1)) * EXP(16, (LENGTH(chHEX) 
                  - inj)).
        ELSE
            ININTEGER = ININTEGER + (KEYCODE(SUBSTRING(chHEX, inj, 1)) 
              - KEYCODE("A") + 10) * EXP(16, (LENGTH(chHEX) - inj)).
    END.
         
    RETURN ININTEGER.
END METHOD.

/* String has numbers */
METHOD PRIVATE LOG HasNumbers (pStr AS CHAR):
    DEF VAR charIndex AS INT NO-UNDO.
    DO charIndex = 1 TO LENGTH(pStr):
        IF INDEX("0123456789", SUBSTRING(pStr, charIndex, 1)) > 0 THEN RETURN TRUE.
    END.
    RETURN False.
END.

/* Formirujem shablon kommentarija iz kommentarija */
METHOD PRIVATE CHAR MakeTemplateFromDetails(pDetails AS CHAR):
    DEF VAR wordIndex     AS INT64 NO-UNDO.
    DEF VAR word          AS CHAR  NO-UNDO.
    DEF VAR outTemplate   AS CHAR  NO-UNDO.
    DEF VAR tagOpened     AS LOG   NO-UNDO. /* false-Undefined, true-Started */
    DEF VAR wordDelimiter AS CHAR  NO-UNDO. 
    
    IF INDEX(pDetails, "[[") > 0 THEN RETURN pDetails.
    
    DO wordIndex = 1 TO NUM-ENTRIES(pDetails, " "):
        word = ENTRY(wordIndex, pDetails, " ") NO-ERROR.
        IF HasNumbers(word) THEN 
         DO:
            IF tagOpened THEN
             DO:
                wordDelimiter = "]] ".
                tagOpened = false.
             END.
            ELSE
                wordDelimiter = " ".
         END.
        ELSE
         DO:
            IF tagOpened THEN
                wordDelimiter = " ".
            ELSE
             DO:
                wordDelimiter = " [[".
                tagOpened = true.
             END.
         END.
        outTemplate = outTemplate + wordDelimiter + word.
    END.
    outTemplate = TRIM(outTemplate).
    IF tagOpened THEN outTemplate = outTemplate + "]]".
    RETURN outTemplate.
END.


    DEF VAR tabl1 as character extent 88 initial
    [ "Ā", "ā", "Č", "č", "Ē", "ē", "Ģ", "ģ", "Ī", "ī", "Ķ", 
      "ķ", "Ļ", "ļ", "Ņ", "ņ", "Š", "š", "Ū", "ū", "Ž", "ž",
      ">", "<", "А", "Б", "В", "Г", "Д", "Е", "Ж", "З", "И", 
      "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", 
      "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", 
      "Я", "а", "б", "в", "г", "д", "е", "ж", "з", "и", "й", 
      "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", 
      "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я"]. 

    DEF VAR tabl2 as character extent 88 initial
    [ "A", "a", "C", "c", "E", "e", "G", "g", "I", "i", "K", 
      "k", "L", "l", "N", "n", "S", "s", "U", "u", "Z", "z",
      "]", "[", "A", "B", "V", "G", "D", "E", "ZH","Z", "I", 
      "Y", "K", "L", "M", "N", "O", "P", "R", "S", "T", "U", 
      "F", "H", "C", "CH","SH","SH","'", "Y", "'", "E", "YU", 
      "YA","a", "b", "v", "g", "d", "e","zh","z", "i", "y", 
      "k", "l", "m", "n", "o", "p", "r", "s", "t", "u", "f", 
      "h", "c", "ch","sh","sh","'", "y", "'", "e", "yu", "ya"].

    DEF VAR translitTab   AS CHAR EXTENT 256.
    DEF VAR translitLang  AS CHAR EXTENT 256.
   
    DEF VAR translitTabOk AS LOG  INIT FALSE.
    METHOD LOG InitTranslit():
        IF translitTabOk THEN RETURN translitTabOk.
        DEF VAR i AS INT64 NO-UNDO.
        DO i = 1 TO 256:
            translitTab[i] = CHR(i).
        END.
        DO i = 1 TO 88:
            IF ASC(tabl1[i]) > 0 THEN
             DO:
                translitTab[ASC(tabl1[i])] = tabl2[i].
                translitLang[ASC(tabl1[i])] = "RU".
                IF i < 23 THEN 
                    translitLang[ASC(tabl1[i])] = "LV".
             END.
        END.
        translitTabOk = TRUE.
        RETURN translitTabOk.
    END.
    
    METHOD PRIVATE CHAR translitString (pText AS CHAR):
        RETURN translitString(pText, false).
    END.
    
    METHOD PRIVATE CHAR translitString (pText AS CHAR, pTranslinOnlyLv AS LOG):
        DEF VAR i      AS INT64.
        DEF VAR chn    AS INT64.
        DEF VAR n      AS INT64.
        DEF VAR ch     AS CHAR.
        InitTranslit().
        n = length(pText).

        DO i = n TO 1 BY -1:
            ch = substring(pText, i, 1).
            chn = ASC(ch).
            IF translitLang[chn] <> "LV" AND pTranslinOnlyLv THEN NEXT.
            IF ch <> translitTab[chn] THEN
             DO:
                SUBSTRING(pText, i, 1) = translitTab[chn].
             END.
            
        END.

        REPEAT:
          IF index(pText,"  ") = 0 THEN leave.
          pText = REPLACE(pText, "  ", " ").
        end.
        RETURN pText.
    END.

    
    DEF TEMP-TABLE trlt NO-UNDO
    FIELD CFROM AS CHAR
    FIELD CTO   AS CHAR.

    METHOD PRIVATE INT64 FILL_TRLT_TABLE (INPUT INPUT_CFROM AS CHAR, INPUT INPUT_CTO AS CHAR):
        CREATE trlt.
        ASSIGN trlt.CFROM   = INPUT_CFROM
               trlt.CTO     = INPUT_CTO.
    END.

    METHOD PRIVATE CHARACTER translitStringIso(iAddress AS CHAR):
        DEF VAR ii AS INT64 NO-UNDO.
        DEF VAR oAddress AS CHAR.
        translitStringIsoFill().
        oAddress = "".
        DO ii = 1 TO LENGTH(iAddress):
            FIND FIRST trlt WHERE trlt.cfrom EQ SUBSTRING(iAddress, ii, 1) NO-ERROR.
            IF AVAILABLE trlt THEN oAddress = oAddress + trlt.cto.
            ELSE oAddress = oAddress + SUBSTRING(iAddress, ii, 1).
        END.
        RETURN oAddress.
    END. 

    METHOD PRIVATE CHARACTER translitStringIsoFill():
        FIND FIRST trlt NO-LOCK NO-ERROR.
        IF AVAILABLE trlt THEN RETURN "".
        
        FILL_TRLT_TABLE("А", "a").
        FILL_TRLT_TABLE("Б", "b").
        FILL_TRLT_TABLE("В", "v").
        FILL_TRLT_TABLE("Г", "g").
        FILL_TRLT_TABLE("Д", "d").
        FILL_TRLT_TABLE("Е", "e").
        FILL_TRLT_TABLE("Ē", "e").
        FILL_TRLT_TABLE("Ж", "zh").
        FILL_TRLT_TABLE("З", "z").
        FILL_TRLT_TABLE("И", "i").
        FILL_TRLT_TABLE("Й", "i").
        FILL_TRLT_TABLE("К", "k").
        FILL_TRLT_TABLE("Л", "l").
        FILL_TRLT_TABLE("М", "m").
        FILL_TRLT_TABLE("Н", "n").
        FILL_TRLT_TABLE("О", "o").
        FILL_TRLT_TABLE("П", "p").
        FILL_TRLT_TABLE("Р", "r").
        FILL_TRLT_TABLE("С", "s").
        FILL_TRLT_TABLE("Т", "t").
        FILL_TRLT_TABLE("У", "u").
        FILL_TRLT_TABLE("Ф", "f").
        FILL_TRLT_TABLE("Х", "kh").
        FILL_TRLT_TABLE("Ц", "ts").
        FILL_TRLT_TABLE("Ч", "ch").
        FILL_TRLT_TABLE("Ш", "sh").
        FILL_TRLT_TABLE("Щ", "shch").
        FILL_TRLT_TABLE("Ъ", "ie").
        FILL_TRLT_TABLE("Ы", "y").
        FILL_TRLT_TABLE("Ь", "").
        FILL_TRLT_TABLE("Э", "e").
        FILL_TRLT_TABLE("Ю", "iu").
        FILL_TRLT_TABLE("Я", "ia").
        RETURN "".
    END.
    
    /* Progress BugFix for non ascii simbols */
    METHOD PRIVATE CHAR correctUtfStringLengh (pStr as char):
        DEF VAR indexChar AS INT NO-UNDO.
        DEF VAR counter AS INT NO-UNDO.
        counter = 0.
        DO indexChar = 1 TO length(pStr):
          IF INDEX("ИЖСЙЕМЦЬЫГУЗТШБЮОПНКДФЩЪВЯЛХРЭАЧēūīāšģķļžčņ",substring(pStr,indexChar,1)) <> 0 THEN
           DO:
              counter = counter + 1.
           END.
        END.
        IF counter > 0 THEN pStr = pStr + fill("_", counter).
        RETURN(pStr).
    END.


/***********************************************************************/
/*** STR_GET_DATATYPE_BY_FORMAT RETURN                               ***/
/*** 1 - CHAR                                                        ***/
/*** 2 - DEC/INT                                                     ***/
/*** 3 - DATE                                                        ***/
/*** 4 - LOGICAL                                                     ***/
/*** Other - UNDEFINED                                               ***/
/***********************************************************************/

METHOD PRIVATE INT64 get_Datatype_By_Format (iFormat AS CHAR):     
    DEF VAR f_DataType AS INT64 NO-UNDO.
    DEF VAR f_Dot1     AS INT64 NO-UNDO.
    DEF VAR f_Dot2     AS INT64 NO-UNDO.
    DEF VAR f_Dot3     AS INT64 NO-UNDO.
    DEF VAR f_Dot4     AS INT64 NO-UNDO.
     
    f_DataType = 1. /* CHAR */
    f_Dot1 = INDEX(iFormat, ".").
    f_Dot2 = INDEX(iFormat, ".", f_Dot1 + 1).
    f_Dot3 = INDEX(iFormat, "/").
    f_Dot4 = INDEX(iFormat, "/", f_Dot1 + 1).

    IF (INDEX(iFormat, "X") > 0) THEN
        f_DataType = 1. /* CHAR */
    ELSE IF INDEX(iFormat, ":") > 0 THEN
        f_DataType = 2. /* INTEGER / TIME */
    ELSE IF (f_Dot1 > 0 AND f_Dot2 > 0) OR
            (f_Dot3 > 0 AND f_Dot4 > 0) THEN
        f_DataType = 3. /* DATE */
    ELSE IF (f_Dot3 > 0) THEN
         f_DataType = 4. /* LOGICAL */
    ELSE IF (INDEX(iFormat, "9") > 0 OR
             INDEX(iFormat, "z") > 0) THEN
         f_DataType = 2. /* DECIMAL */
    RETURN f_DataType.
END.    


/*****************************************************************************/
/*** STR_FORMAT_LENGTH  returns length of format string                    ***/
/*** f_Format   - Format string                                            ***/
/*** f_DataType - (0 - 4) Type of data by format                           ***/
/***               0 - Autodetect data type                                ***/
/*****************************************************************************/
METHOD PRIVATE INT64 get_Format_Length (f_Format AS CHAR, f_DataType AS INT64):
    DEF VAR f_Len AS INT64.
    IF f_DataType <= 0 THEN 
        f_DataType = get_Datatype_By_Format(f_Format).
    
    IF f_DataType = 1 THEN
        f_Len = LENGTH(STRING(" ", f_Format)).
    ELSE IF f_DataType <> 4 THEN
        f_Len = LENGTH(f_Format).
    ELSE
     DO:
        f_Len = 8.
        f_Len = MAX(LENGTH(ENTRY(1, f_Format, "/")),
                    LENGTH(ENTRY(2, f_Format, "/"))) NO-ERROR.
     END.
    RETURN f_Len.
END.

METHOD PRIVATE CHAR getFirstNotEmpty (iStr1 AS CHAR, iStr2 AS CHAR, iStr3 AS CHAR):
    IF iStr1 <> "" AND iStr1 <> ? THEN RETURN iStr1.
    IF iStr2 <> "" AND iStr2 <> ? THEN RETURN iStr2.
    IF iStr3 = ?                  THEN RETURN "".
    RETURN iStr3.
END.

    METHOD PRIVATE INT64 RINDEX(Txt AS LONGCHAR, Src AS CHAR, Start AS INT64):
        DEF VAR Lng AS INT NO-UNDO.
        DEF VAR i   AS INT NO-UNDO.
        Lng = LENGTH(Src).
        DO i = Start TO 1 BY -1:
            IF SUBSTRING(Txt, i, Lng) = Src THEN RETURN i.
        END.
        RETURN 0.
    END.
    
    /*Объединяет в красивую строку с запятыми, использовать так SUBSTITUTE("&1|&2|&3", a, b, c)*/
    METHOD PRIVATE CHARACTER FillMerge (cList AS CHARACTER):
        DEFINE VARIABLE cReturn AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO NUM-ENTRIES(cList, "|"):
            IF LENGTH(TRIM(ENTRY(i, cList, "|"))) > 0 THEN DO:
                IF LENGTH(cReturn) > 0 THEN cReturn = cReturn + ', '.
                cReturn = cReturn + TRIM(ENTRY(i, cList, "|")).
            END.
        END.
        RETURN cReturn.
    END METHOD.
    
    /*Поиск даты в строке*/
    METHOD PRIVATE DATE SearchDate (cString AS CHARACTER):
        DEFINE VARIABLE i AS INT64 NO-UNDO.
        DEFINE VARIABLE cPossibleDate AS CHARACTER NO-UNDO.
        DEFINE VARIABLE dtReturn AS DATE NO-UNDO.
        
        DO i = 1 TO LENGTH(cString):
            cPossibleDate = SUBSTRING(cString, i, 10).
            
            IF LENGTH(cPossibleDate) EQ 10 THEN DO:
                IF ASC(SUBSTRING(cPossibleDate, 1, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 1, 1)) <= 57
                AND ASC(SUBSTRING(cPossibleDate, 2, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 2, 1)) <= 57
                AND LOOKUP(SUBSTRING(cPossibleDate, 3, 1), '.,/') > 0
                AND ASC(SUBSTRING(cPossibleDate, 4, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 4, 1)) <= 57
                AND ASC(SUBSTRING(cPossibleDate, 5, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 5, 1)) <= 57
                AND LOOKUP(SUBSTRING(cPossibleDate, 6, 1), '.,/') > 0
                AND ASC(SUBSTRING(cPossibleDate, 7, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 7, 1)) <= 57
                AND ASC(SUBSTRING(cPossibleDate, 8, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 8, 1)) <= 57
                AND ASC(SUBSTRING(cPossibleDate, 9, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 9, 1)) <= 57
                AND ASC(SUBSTRING(cPossibleDate, 10, 1)) >= 48 AND ASC(SUBSTRING(cPossibleDate, 10, 1)) <= 57
                THEN DO:
                    dtReturn = DATE(
                        INTEGER(SUBSTRING(cPossibleDate, 4, 2)),
                        INTEGER(SUBSTRING(cPossibleDate, 1, 2)),
                        INTEGER(SUBSTRING(cPossibleDate, 7, 4))
                    ) NO-ERROR.
                    LEAVE.
                END.
            END.
            ELSE LEAVE.
        END.
        RETURN dtReturn.
    END METHOD.
    
    METHOD PRIVATE CHARACTER FormatDec(dVal AS DECIMAL, iDecimals AS INT64, cDischarge AS CHARACTER):
        DEFINE VARIABLE dDecimalPart AS DECIMAL NO-UNDO.
        DEFINE VARIABLE cDecimalPart AS CHARACTER NO-UNDO.
        DEFINE VARIABLE dIntegerPart AS DECIMAL NO-UNDO.
        DEFINE VARIABLE cIntegerPart AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFormatted AS CHARACTER NO-UNDO.
        
        DEFINE VARIABLE cDecimalPoint AS CHARACTER NO-UNDO INITIAL ".".
        DEFINE VARIABLE cMinus AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cSpace AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i AS INT64 NO-UNDO.
        DEFINE VARIABLE j AS INT64 NO-UNDO.
        
        IF iDecimals > 24 THEN iDecimals = 24.
        dVal = ROUND(dVal, iDecimals).
        
        /*Poluchenie celoj chasti*/
        dIntegerPart = TRUNCATE(ABSOLUTE(dVal), 0).
        cIntegerPart = STRING(dIntegerPart).
        
        DO i = LENGTH(cIntegerPart) TO 1 BY -1:
            IF j EQ 3 THEN DO:
                j = 0.
                cSpace = cDischarge.
            END.
            ELSE cSpace = "".
            cFormatted = SUBSTRING(cIntegerPart, i, 1) + cSpace + cFormatted.
            j = j + 1.
        END.
        
        /*Poluchenie drobnoj chasti*/
        dDecimalPart = (ABSOLUTE(dVal) - dIntegerPart + 1) * EXP(10, iDecimals).
        cDecimalPart = STRING(dDecimalPart).
        cDecimalPart = SUBSTRING(cDecimalPart, LENGTH(cDecimalPart) - iDecimals + 1, iDecimals).
        
        IF iDecimals EQ 0 THEN cDecimalPoint = "".
        IF dVal < 0 THEN cMinus = "-".
        
        RETURN cMinus + cFormatted + cDecimalPoint + cDecimalPart.
    END METHOD.
    
    /* Returns: TRUE - if */
    METHOD PRIVATE LOG hasRussianAlfabetSimbols(Str as char):
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE alfabet AS CHARACTER NO-UNDO.
        
        /*lat_str = "ĒŪĪĀŠĢĶĻŽČŅēūīāšģķļžčņАБВГДЕĒЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеēжзийклмнопрстуфхцчшщъыьэюя".*/
        alfabet = "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя".

        DO i = 1 TO LENGTH(str):
            IF INDEX(alfabet, SUBSTRING(str, i, 1)) > 0 THEN RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.

    METHOD PRIVATE LOG hasLatvianAlfabetSpecialSimbols(Str as char):
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE alfabet AS CHARACTER NO-UNDO.

        alfabet = "ĒŪĪĀŠĢĶĻŽČŅēūīāšģķļžčņ".

        DO i = 1 TO LENGTH(str):
            IF INDEX(alfabet, SUBSTRING(str, i, 1)) > 0 THEN RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.

    METHOD PRIVATE LOG hasNonAsciiSimbols(iStr as char):
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
        
        DO i = 1 TO LENGTH(iStr):
            IF ASC(SUBSTRING(iStr, i, 1)) > 127 THEN RETURN TRUE.
        END.
        
        RETURN FALSE.
    END.
    
    METHOD PRIVATE INT getLabelStartPosition(iStr as CHARACTER, iSemicolonPosition AS INTEGER, iOnlyOneWordInLabel AS LOG):
        DEFINE VARIABLE i                        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE tChar                    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE tLabelStarted            AS INTEGER NO-UNDO.
        DEFINE VARIABLE tFirstWordPosition       AS INTEGER NO-UNDO.
        DEFINE VARIABLE tFirstDelimiterPosition  AS INTEGER NO-UNDO.
        
        DO i = iSemicolonPosition - 1 TO 1 BY -1:
            tChar = SUBSTRING(iStr, i, 1).
            IF tChar <> " "      AND tLabelStarted = 0       THEN tLabelStarted = i.
            IF tLabelStarted > 0 AND tChar = " "             THEN 
             DO:
                tFirstWordPosition = i.
                IF iOnlyOneWordInLabel THEN 
                 DO:
                    tFirstDelimiterPosition = i.
                    LEAVE.
                 END.
             END.
            IF tLabelStarted > 0 AND INDEX(":,;", tChar) > 0 THEN 
             DO: 
                IF tChar = ":" THEN 
                    tFirstDelimiterPosition = tFirstWordPosition.
                ELSE
                    tFirstDelimiterPosition = i.
                LEAVE.
             END.
        END.
        
        IF tFirstDelimiterPosition > 0 THEN RETURN tFirstDelimiterPosition.
        IF tFirstWordPosition > 0      THEN RETURN tFirstWordPosition.
        
        IF i <= 1 THEN RETURN 0.
        
        RETURN i.
    END.
    
    METHOD PRIVATE CHAR insertReturnBeforeLabelAndSemicolon (iStr AS CHAR, iOnlyOneWordInLabel AS LOG):
        DEFINE VARIABLE tNextLabelPosition     AS INTEGER   NO-UNDO.
        DEFINE VARIABLE tStartOfLabelPosition  AS INTEGER   NO-UNDO.
        
        tNextLabelPosition = INDEX(iStr, ":").
        
        DO WHILE tNextLabelPosition > 0:
            tStartOfLabelPosition = getLabelStartPosition(iStr, tNextLabelPosition, iOnlyOneWordInLabel).

            IF tStartOfLabelPosition > 0 THEN 
             DO:
                IF SUBSTRING(iStr, tStartOfLabelPosition, 1) = " " THEN
                    SUBSTRING(iStr, tStartOfLabelPosition, 1) = CHR(10).
                ELSE    
                    iStr = SUBSTRING(iStr, 1, tStartOfLabelPosition) + CHR(10) + SUBSTRING(iStr, tStartOfLabelPosition + 1).
             END.
            tNextLabelPosition = INDEX(iStr, ":", tNextLabelPosition + 2).
        END.
        
        RETURN iStr.
    END.
    
    DEFINE PRIVATE TEMP-TABLE tt_only_chars NO-UNDO
        FIELD ch AS CHARACTER CASE-SENSITIVE
        INDEX ch ch.
    
    METHOD PRIVATE VOID FillOnlyChars():
        DEFINE VARIABLE cChars AS CHARACTER EXTENT NO-UNDO CASE-SENSITIVE INITIAL [
            "AĀBCČDEĒFGĢHIĪJKĶLĻMNŅOPRSŠTUŪVZŽaābcčdeēfgģhiījkķlļmnņoprsštuūvzž",
            "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯабвгдежзийклмнопрстуфхцчшщьыъэюя",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        ].
        DEFINE BUFFER tt_only_chars FOR TEMP-TABLE tt_only_chars.
        DEFINE VARIABLE i AS INT64 NO-UNDO.
        DEFINE VARIABLE j AS INT64 NO-UNDO.
        DEFINE VARIABLE cChar AS CHARACTER NO-UNDO CASE-SENSITIVE.
        
        DO i = 1 TO EXTENT(cChars):
            DO j = 1 TO LENGTH(cChars[i]):
                cChar = SUBSTRING(cChars[i], j, 1).
                FIND FIRST tt_only_chars WHERE tt_only_chars.ch EQ cChar NO-LOCK NO-ERROR.
                IF NOT AVAILABLE tt_only_chars THEN CREATE tt_only_chars.
                ASSIGN
                    tt_only_chars.ch = cChar.
            END.
        END.
    END METHOD.
    
    METHOD PRIVATE LOGICAL IsOnlyChars(cStr AS CHARACTER):
        DEFINE BUFFER tt_only_chars FOR TEMP-TABLE tt_only_chars.
        DEFINE VARIABLE i AS INT64 NO-UNDO.
        
        DO i = 1 TO LENGTH(cStr):
            FIND FIRST tt_only_chars WHERE tt_only_chars.ch EQ SUBSTRING(cStr, i, 1) NO-LOCK NO-ERROR.
            IF NOT AVAILABLE tt_only_chars THEN RETURN FALSE.
        END.
        RETURN TRUE.
    END METHOD.
    
    METHOD PRIVATE CHARACTER GetOnlyChars(cStr AS CHARACTER, cReplaceSymbol AS CHARACTER):
        DEFINE VARIABLE i AS INT64 NO-UNDO.
        DEFINE VARIABLE cReturn AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cChar AS CHARACTER NO-UNDO.
        
        DO i = 1 TO LENGTH(cStr):
            cChar = SUBSTRING(cStr, i, 1).
            IF NOT IsOnlyChars(cChar) THEN cReturn = cReturn + cReplaceSymbol.
            ELSE cReturn = cReturn + cChar.
        END.
        RETURN cReturn.
    END METHOD.
    
END. /* END OF CLASS */

