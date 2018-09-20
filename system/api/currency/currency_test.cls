CLASS syscrc: 
    DEF PUBLIC VAR EUR_RATE     AS DECIMAL NO-UNDO INIT 0.702804. /* лХТУ РЕТЕИПДБ ОБ ечтп */   
    DEF PUBLIC VAR EUR_DT       AS DATE   NO-UNDO INIT 01/01/2014. /* дБФБ РЕТЕИПДБ ОБ ечтп */
    DEF PUBLIC VAR EUR_PLUS_DT  AS DATE   NO-UNDO INIT 10/01/2013. /* дБФБ, У ЛПФПТПК ДМС МБФПЧ РЕЮБФЕФУС Й УХННБ Ч ЕЧТП */
    DEF PUBLIC VAR EUR_ONLY_DT  AS DATE   NO-UNDO INIT 07/01/2014. /* дБФБ, У ЛПФПТПК ДМС ЕЧТП ОЕ РЕЮБФЕФУС УХННБ Ч МБФБИ */
    DEF PUBLIC VAR g-today      AS DATE   NO-UNDO. /* Ubratj public ALEZHU */
    DEF PUBLIC VAR g-Lang       AS CHAR   NO-UNDO INIT "LV".
    DEF VAR cbnk-f              AS INT    NO-UNDO.
    DEF PUBLIC VAR cbnk         AS sysbnk NO-UNDO.
    DEF PUBLIC VAR cmsg         AS sysmsg NO-UNDO.
    DEF PUBLIC VAR NATIONAL_CRC AS INT64  NO-UNDO.
    DEF PUBLIC VAR g-ccy        AS CHAR   NO-UNDO.
    DEF PUBLIC VAR limamt       AS DEC    NO-UNDO.
    
    DEF PUBLIC VAR crcLvl       AS INT64  NO-UNDO INIT 1.     /*OSTAVIT' LATY*/
    DEF PUBLIC VAR codLvl       AS CHAR   NO-UNDO INIT 'LVL'. /*OSTAVIT' LATY*/
    DEF PUBLIC VAR codLs        AS CHAR   NO-UNDO INIT 'Ls'.  /*OSTAVIT' LATY*/
    DEF PUBLIC VAR crcEur       AS INT64  NO-UNDO INIT 1.    /*TUPO EUR*/
    DEF PUBLIC VAR codEur       AS CHAR   NO-UNDO INIT 'GBP'. /*TUPO EUR*/
    DEF private VAR codArr      AS CHAR   NO-UNDO EXTENT 100.
    
    DEF VAR InitMsgOk AS LOG NO-UNDO INIT NO.
    
    DEF BUFFER sysc FOR BANK.sysc.
    
    CONSTRUCTOR syscrc():
        Init().
    END.
    CONSTRUCTOR syscrc(f_cacc AS sysacc):
        cbnk = f_cacc:cbnk.
        Init().
    END.
    CONSTRUCTOR syscrc(f_cbnk AS sysbnk):
        cbnk = f_cbnk.
        Init().
    END.
    DESTRUCTOR syscrc():
        IF cbnk-f = 0 THEN DELETE OBJECT cbnk NO-ERROR.
        IF InitMsgOk THEN DELETE OBJECT cmsg NO-ERROR.
    END.
    METHOD PUBLIC INT Init():
        DEF BUFFER crc  FOR BANK.crc.
        g-today = today.
        cbnk-f  = 1.
        IF NOT VALID-OBJECT(cbnk) THEN
         DO:
            cbnk-f = 0.
            cbnk   = NEW sysbnk().
         END.
        g-today       = cbnk:Get_G_Today().
        
        find sysc where sysc.sysc eq "EUROSTART" no-lock no-error.
        if available sysc AND sysc.daval ne ? then eur_dt = sysc.daval no-error.
        
        NATIONAL_CRC  = BaseCrc(g-today).
        g-ccy         = BaseCcy(g-today).
        
        find first bank.sysc where sysc.sysc = "FXSMALL" no-lock no-error.
        if available sysc then limamt = sysc.deval. else limamt = 0.51.
        for each crc no-lock:
          codArr[crc.crc] = crc.code.
        end.
    END.