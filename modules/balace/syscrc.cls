CLASS syscrc: 
    DEF PUBLIC VAR EUR_RATE     AS DECIMAL NO-UNDO INIT 0.702804. /* Курс перехода на ЕВРО */   
    DEF PUBLIC VAR EUR_DT       AS DATE   NO-UNDO INIT 01/01/2014. /* Дата перехода на ЕВРО */
    DEF PUBLIC VAR EUR_PLUS_DT  AS DATE   NO-UNDO INIT 10/01/2013. /* Дата, с которой для латов печатется и сумма в евро */
    DEF PUBLIC VAR EUR_ONLY_DT  AS DATE   NO-UNDO INIT 07/01/2014. /* Дата, с которой для евро не печатется сумма в латах */
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
    
    METHOD PUBLIC INT InitCrc():
        RETURN InitCrc(g-today).
    END.
    METHOD PUBLIC INT InitCrc(f_Dt AS DATE):
        NATIONAL_CRC   = BaseCrc(f_Dt).
        g-ccy          = BaseCcy(f_Dt).
        RETURN 0.
    END.
    /* Национальная валюта (Код валюты) */
    METHOD PUBLIC INT64 BaseCrc():
        RETURN NATIONAL_CRC.
    END.
    /* Национальная валюта (Код валюты) */
    METHOD PUBLIC INT64 BaseCrc(f_Dt AS DATE):
        RETURN 1.
    END.
    /* Национальная валюта (Буквенный код валюты на дату) */
    METHOD PUBLIC CHAR BaseCcy(f_Dt AS DATE):
        RETURN Ccy(BaseCrc(f_Dt)).
    END.
    /* Национальная валюта (Буквенный код валюты на дату) */
    METHOD PUBLIC CHAR BaseCcy():
        RETURN g-Ccy.
    END.
     
    /* Код валюты по буквенному коду */
    METHOD PUBLIC INT64 Crc(cod AS CHAR):
      def var ii as int64 no-undo.
      if      cod eq "EUR"                then return 11.
      else if cod eq "Ls"  or cod = "LVL" then return 1.
      else if cod eq "USD"                then return 2.
      else if cod eq "RUR" or cod = "RUB" then return 4.
      else if cod eq "GBP"                then return 15.
      else if cod eq "BYB" or cod = "BYR" then return 21.
      else do ii = 1 to 100:
        if codArr[ii] = cod then return ii.
        if codArr[ii] = ""  then leave.
      end.
      return -1.
      /*RETURN cbnk:Get_Crc_By_Code(cod).*/
    END.
    /* INT 2 CHAR */
    METHOD PUBLIC CHAR Ccy(f_Crc AS INT64):
        if f_Crc le 0 or f_Crc gt 100 then return "".
        if      f_Crc eq crcLvl then return codLvl.
        else if f_Crc eq crcEur then return codEur.
        else RETURN codArr[f_Crc].
        /*RETURN cbnk:Get_Code_By_Crc_A(f_Crc).*/
    END.
    
    METHOD PUBLIC CHAR Des(f_Crc AS INT64):
        RETURN cbnk:Get_Des_By_Crc(f_Crc).
    END.
     
    METHOD INT InitMsg ():
        IF InitMsgOk THEN RETURN 0.
        IF NOT VALID-OBJECT(cmsg) THEN cmsg = NEW sysmsg().
        InitMsgOk = yes.
        RETURN 0.
    END.
    
    DEF VAR NameSex AS INT64 NO-UNDO INIT 1.
    METHOD PUBLIC CHAR Name(f_Crc AS INT64, f_Lang AS CHAR):
        InitMsg().
        RETURN cmsg:SM-CCY(f_Crc, f_Lang, NameSex).
    END.
    METHOD PUBLIC CHAR Name(f_Crc AS INT64):
        InitMsg().
        RETURN cmsg:SM-CCY(f_Crc, g-lang, NameSex).
    END.
    
    METHOD PUBLIC CHAR BaseName(f_Dt AS DATE, f_Lang AS CHAR):
        InitMsg().
        DEF VAR f_Crc AS INT64 NO-UNDO.
        f_Crc = BAseCrc(f_Dt).
        RETURN cmsg:SM-CCY(f_Crc, f_Lang, NameSex).
    END.
    METHOD PUBLIC CHAR BaseName(f_Dt AS DATE):
        InitMsg().
        DEF VAR f_Crc AS INT64 NO-UNDO.
        f_Crc = BaseCrc(f_Dt).
        RETURN cmsg:SM-CCY(f_Crc, g-Lang, NameSex).
    END.
    
    METHOD PUBLIC CHAR BaseName(f_Lang AS CHAR):
        InitMsg().
        RETURN cmsg:SM-CCY(NATIONAL_CRC, f_Lang, NameSex).
    END.
    METHOD PUBLIC CHAR BaseName():
        InitMsg().
        RETURN cmsg:SM-CCY(NATIONAL_CRC, g-lang, NameSex).
    END.
    
    METHOD PUBLIC DEC Get_Crc_Rate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64):
        RETURN Get_Crc_Rate(f_Crc, f_Dt, f_typ, 99999).
    END.
    
    METHOD PUBLIC DEC Get_Crc_Rate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64, f_tim AS INT64):
        def var rat as dec no-undo.
        IF f_typ = 0 then f_typ = 1.
        IF f_typ = 1 AND f_Dt >= EUR_DT THEN f_typ = 10.
        rat = cbnk:Get_Crc_Rate(f_Crc, f_Dt, f_typ, f_Tim).
        if rat = ? then rat = 0.
        RETURN rat.
    END.
    
    METHOD PUBLIC DEC Get_Crc_Rate_Lb(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64):
        def var rat as dec no-undo.
        IF f_typ = 0 then f_typ = 1.
        rat = Get_Crc_Rate(f_Crc, f_Dt, f_typ).
        IF f_Dt >= EUR_DT THEN rat = 1 / rat.
        if rat = ? then rat = 0.
        RETURN rat.
    END.
    METHOD PUBLIC CHAR Cntry_by_crc(f_Crc AS INT64):
        RETURN cbnk:GET_CNTRY_BY_CRC(f_Crc).
    END.    
    METHOD PUBLIC CHAR Cntry_by_crc(f_ccy as char):
        RETURN cbnk:GET_CNTRY_BY_CRC(crc(f_ccy)).
    END.  
  
    /* возвращает курс валюты на дату (simplified copy of cbnk:Get_Crc_rate)*/ 
    /* NOT USED YET!!! */
    METHOD PUBLIC DEC GetCrcRate(crc as int64,dat as dat,typ as int64):
      def buffer crchis for bank.crchis.
      def var rat as dec no-undo.
    
      if crc eq 0 then return 0.
      if dat eq ? then dat = G-TODAY.
      if typ lt 1 or typ gt 10 then typ = 1.
    
      find last crchis where crchis.crc eq crc and 
                             crchis.rdt lt dat + 1
                             use-index crcrdt no-lock no-error.
      if not avail crchis then return 0.
      if dat lt EUR_DT then do:
        if typ eq 10 
        then rat = crchis.rate[9] / crchis.rate[1] no-error.
        else rat = crchis.rate[typ] / crchis.rate[9] no-error.
      end.
      else do:
        if crchis.rdt lt EUR_DT then return 0.
        if typ eq 10
        then rat = crchis.rate[9] / crchis.rate[1] no-error.
        else rat = crchis.rate[typ] / crchis.rate[1] no-error.
      end.
      if rat eq ? then rat = 0.
      return rat.
    END.
  
  
  
    /** Возвращает конкретный курс валюты на дату (по буквенному коду) **/
    METHOD PUBLIC DEC Rate(f_Crc AS CHAR, f_Dt AS DATE, f_typ AS INT64):
        RETURN Get_Crc_Rate(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, f_typ).
    END.
    /* Возвращает конкретный курс валюты на дату */
    METHOD PUBLIC DEC Rate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64):
        RETURN Get_Crc_Rate(f_Crc, f_Dt, f_typ).
    END.
    
    /* Возвращает конкретный курс валюты на дату + время */
    METHOD PUBLIC DEC Rate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64, f_tim AS INT64):
        RETURN Get_Crc_Rate(f_Crc, f_Dt, f_typ, f_tim).
    END.
                                      
   /** Возвращает курс валюты на дату (по буквенному коду) **/
    METHOD PUBLIC DEC Rate(f_Crc AS CHAR, f_Dt AS DATE):
        RETURN Get_Crc_Rate(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, 1).
    END.
    /* Возвращает курс валюты на дату */
    METHOD PUBLIC DEC Rate(f_Crc AS INT64, f_Dt AS DATE):
        RETURN Get_Crc_Rate(f_Crc, f_Dt, 1).
    END.
    /** Возвращает конкретный курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC Rate(f_Crc AS CHAR, f_typ AS INT64):
        RETURN Get_Crc_Rate(cbnk:Get_Crc_By_Code(f_Crc), g-today, f_typ).
    END.
    /* Возвращает конкретный курс валюты на g-today */
    METHOD PUBLIC DEC Rate(f_Crc AS INT64, f_typ AS INT64):
        RETURN Get_Crc_Rate(f_Crc, g-today, f_typ).
    END.
     
    /** Возвращает курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC Rate(f_Crc AS CHAR):
        RETURN Get_Crc_Rate(cbnk:Get_Crc_By_Code(f_Crc), g-today, 1).
    END.
    /* Возвращает курс валюты на g-today */
    METHOD PUBLIC DEC Rate(f_Crc AS INT64):
        RETURN Get_Crc_Rate(f_Crc, g-today, 1).
    END.
    /* Курс в формате Банка Латвии (УМНОЖЕНИЕ НА КУРС) */
    /** Возвращает конкретный курс валюты на дату (по буквенному коду) **/
    METHOD PUBLIC DEC LbRate(f_Crc AS CHAR, f_Dt AS DATE, f_typ AS INT64):
        RETURN Get_Crc_Rate_Lb(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, f_typ).
    END.
    /* Возвращает конкретный курс валюты на дату */
    METHOD PUBLIC DEC LbRate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64):
        RETURN Get_Crc_Rate_Lb(f_Crc, f_Dt, f_typ).
    END.
                                      
   /** Возвращает курс валюты на дату (по буквенному коду) **/
    METHOD PUBLIC DEC LbRate(f_Crc AS CHAR, f_Dt AS DATE):
        RETURN Get_Crc_Rate_Lb(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, 1).
    END.
    /* Возвращает курс валюты на дату */
    METHOD PUBLIC DEC LbRate(f_Crc AS INT64, f_Dt AS DATE):
        RETURN Get_Crc_Rate_Lb(f_Crc, f_Dt, 1).
    END.
    /** Возвращает конкретный курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC LbRate(f_Crc AS CHAR, f_typ AS INT64):
        RETURN Get_Crc_Rate_Lb(cbnk:Get_Crc_By_Code(f_Crc), g-today, f_typ).
    END.
    /* Возвращает конкретный курс валюты на g-today */
    METHOD PUBLIC DEC LbRate(f_Crc AS INT64, f_typ AS INT64):
        RETURN Get_Crc_Rate_Lb(f_Crc, g-today, f_typ).
    END.
     
    /** Возвращает курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC LbRate(f_Crc AS CHAR):
        RETURN Get_Crc_Rate_Lb(cbnk:Get_Crc_By_Code(f_Crc), g-today, 1).
    END.
    /* Возвращает курс валюты на g-today */
    METHOD PUBLIC DEC LbRate(f_Crc AS INT64):
        RETURN Get_Crc_Rate_Lb(f_Crc, g-today, 1).
    END.
    
    
    
    
   /* Курс из оригинального поля Евро Ценра банка (ДЕЛЕНИЕ НА КУРС) */
   
    /** Возвращает конкретный курс валюты на дату (по буквенному коду) **/
    METHOD PUBLIC DEC EcbRate(f_Crc AS CHAR, f_Dt AS DATE, f_typ AS INT64):
        RETURN EcbRate(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, f_typ).
    END.
    /* Возвращает конкретный курс валюты на дату */
    METHOD PUBLIC DEC EcbRate(f_Crc AS INT64, f_Dt AS DATE, f_typ AS INT64):
        DEF VAR Rate AS DEC NO-UNDO.
        IF f_Dt < EUR_DT THEN
         DO:
            IF f_typ = 10 THEN f_typ = 1. 
            Rate = 1 / cbnk:Get_Crc_Rate(f_Crc, f_Dt, f_typ).
         END.   
        ELSE IF f_typ = 1 or f_typ = 10 THEN
            Rate = cbnk:Get_Crc_Rate(f_Crc, f_Dt, 10).
        ELSE     
            Rate = cbnk:Get_Crc_Rate(f_Crc, f_Dt, f_Typ).
        if Rate = ? then Rate = 0.
        RETURN Rate.
    END.
   /** Возвращает курс валюты на дату (по буквенному коду) **/
   /* Курс из оригинального поля Евро Ценра банка */
    METHOD PUBLIC DEC EcbRate(f_Crc AS CHAR, f_Dt AS DATE):
        RETURN EcbRate(cbnk:Get_Crc_By_Code(f_Crc), f_Dt, 1).
    END.
    /* Возвращает курс валюты на дату */
    METHOD PUBLIC DEC EcbRate(f_Crc AS INT64, f_Dt AS DATE):
        RETURN EcbRate(f_Crc, f_Dt, 1).
    END.
    
    /** Возвращает конкретный курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC EcbRate(f_Crc AS CHAR, f_typ AS INT64):
        RETURN EcbRate(cbnk:Get_Crc_By_Code(f_Crc), g-today, f_typ).
    END.
    /* Возвращает конкретный курс валюты на g-today */
    METHOD PUBLIC DEC EcbRate(f_Crc AS INT64, f_typ AS INT64):
        RETURN EcbRate(f_Crc, g-today, f_typ).
    END.
    /** Возвращает курс валюты на g-today (по буквенному коду) **/
    METHOD PUBLIC DEC EcbRate(f_Crc AS CHAR):
        RETURN EcbRate(cbnk:Get_Crc_By_Code(f_Crc), g-today, 1).
    END.
    /* Возвращает курс валюты на g-today */
    METHOD PUBLIC DEC EcbRate(f_Crc AS INT64):
        RETURN EcbRate(f_Crc, g-today, 1).
    END.
    /* возвращает BRANCH курс [2-7] валюты на дату */   
    METHOD PUBLIC DEC BrRate(crc as int64,
                             typ as int64):
      return BrRate(crc,G-TODAY,typ,3).
    END.
    /* возвращает BRANCH курс [2-7] валюты на дату */   
    METHOD PUBLIC DEC BrRate(crc as int64,
                             typ as int64,
                             stc as int64):
      return BrRate(crc,G-TODAY,typ,stc).
    END.
    /* возвращает BRANCH курс [2-7] валюты на дату */
    METHOD PUBLIC DEC BrRate(crc as int64,
                             dat as dat,
                             typ as int64):
      return BrRate(crc,dat,typ,3).
    END.                                                                                               
    /* возвращает BRANCH курс [2-7] валюты на дату */   
    METHOD PUBLIC DEC BrRate(crc as int64,
                             dat as dat,
                             typ as int64,
                             stc as int64):
      def var rat as dec no-undo.
      def buffer crcbr for bank.crcbr.
      def buffer crcbrhis for bank.crcbrhis.
      if crc eq 0 then return 0.
      if dat eq ? then dat = G-TODAY.
      if typ lt 2 or typ gt 7 then return 0.
      if stc lt 2 then return 0.
      
      if dat eq G-TODAY then do:
        find first crcbr where crcbr.crc eq crc and 
                               crcbr.grp eq stc no-lock no-error.
        if avail crcbr then do:
          if dat lt EUR_DT then do:
            rat = crcbr.rate[typ] / crcbr.rate[9].
          end.
          else do:
            rat = crcbr.rate[typ] / crcbr.rate[1].
          end.
        end.
      end.
      else do:
        find last crcbrhis where crcbrhis.crc eq crc and 
                                 crcbrhis.rdt lt dat + 1 and
                                 crcbrhis.grp eq stc 
                                 use-index crcrdt no-lock no-error.
        if avail crcbrhis then do:
          if dat lt EUR_DT then do:
            rat = crcbrhis.rate[typ] / crcbrhis.rate[9].
          end.
          else do:
            if crcbrhis.rdt lt EUR_DT then rat = 0.
            else rat = crcbrhis.rate[typ] / crcbrhis.rate[1].
          end.
        end.
      end.
      if rat eq ? then rat = 0.
      return rat.
    END.
   
    /* AMT in CRC1 -> BaseCrc (CB rate) for TODAY */
    /* USAGE: ccrc:Amt(amt,crc1).                 */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64):
      return convAmt(amt,crc1,1,BaseCrc(),1,0,0,G-TODAY).
    END.
    
    /* AMT in CRC1 -> BaseCrc (CB rate) for DAT */
    /* USAGE: ccrc:Amt(amt,crc1,dat)            */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,
                          dat AS DAT):
      return convAmt(amt,crc1,1,BaseCrc(dat),1,0,0,dat).
    END.
    
    /* AMT in CRC1 -> BaseCrc (rate N1) for TODAY */
    /* USAGE: ccrc:Amt(amt,crc1,n1)               */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64):
      return convAmt(amt,crc1,n1,BaseCrc(),1,0,0,G-TODAY).
    END.
    
    /* AMT in CRC1 -> BaseCrc (rate N1) for DAT */
    /* USAGE: ccrc:Amt(amt,crc1,n1,dat)         */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          dat AS DAT):
      return convAmt(amt,crc1,n1,BaseCrc(dat),1,0,0,dat).
    END.
    
    /* AMT in BaseCrc (CRC1) -> CRC2 (rate N2) for TODAY */
    /* USAGE: ccrc:Amt(amt,crc1,crc2,n2)                 */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,
                          crc2 AS INT64,n2 AS INT64):
      return convAmt(amt,crc1,1,crc2,n2,0,0,G-TODAY).
    END.
    
    /* AMT in BaseCrc (CRC1) -> CRC2 (rate N2) for DAT */
    /* USAGE: ccrc:Amt(amt,crc1,crc2,n2,dat)           */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,
                          crc2 AS INT64,n2 AS INT64,
                          dat AS DAT):
      return convAmt(amt,crc1,1,crc2,n2,0,0,dat).
    END.                           
    
    /* AMT in CRC1 -> BaseCrc (rate N1) -> CRC2 (rate N2) for TODAY */
    /* USAGE: cccrc:Amt(amt,crc1,n1,crc2,n2)                        */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          crc2 AS INT64,n2 AS INT64):
      return convAmt(amt,crc1,n1,crc2,n2,0,0,G-TODAY).
    END.
    
    /* AMT in CRC1 -> BaseCrc (rate N1) -> CRC2 (rate N2) for DAT */
    /* USAGE: ccrc:Amt(amt,crc1,n1,crc2,n2,dat)                   */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          crc2 AS INT64,n2 AS INT64,
                          dat AS DAT):
      return convAmt(amt,crc1,n1,crc2,n2,0,0,dat).
    END.
    
    /* AMT in CRC1 -> BaseCrc (rate N1) -> CRC2 (rate N2) for DAT + TIME */
    /* USAGE: ccrc:Amt(amt,crc1,n1,crc2,n2,dat,tim)                      */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          crc2 AS INT64,n2 AS INT64,
                          dat AS DAT, tim AS INT64):
        return convAmt(amt,crc1,n1,crc2,n2,0,0,dat,tim).
    END.
    
    /* AMT in CRC1 -> BaseCrc (rate N1) -> CRC2 (rate N2) for TODAY */
    /* USAGE: ccrc:Amt(amt,crc1,n1,crc2,n2,rat1,rat2)               */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          crc2 AS INT64,n2 AS INT64,
                          rat1 as dec,  rat2 as dec):
      return convAmt(amt,crc1,n1,crc2,n2,rat1,rat2,G-TODAY).
    END.
    /* AMT in CRC1 -> BaseCrc (rate N1) -> CRC2 (rate N2) for DAT */
    /* USAGE: ccrc:Amt(amt,crc1,n1,crc2,n2,rat1,rat2,dat)         */
    METHOD PUBLIC DEC Amt(amt AS DEC,
                          crc1 AS INT64,n1 AS INT64,
                          crc2 AS INT64,n2 AS INT64,
                          rat1 as dec,  rat2 as dec,
                          dat AS DAT):
      return convAmt(amt,crc1,n1,crc2,n2,rat1,rat2,dat).
    END.
    METHOD PUBLIC DEC AmtR(amt as dec,rat1 AS DEC,rat2 AS DEC):
      return convAmt(amt,0,0,0,0,rat1,rat2,G-TODAY).
    END.
    
    METHOD PUBLIC DEC convAmt(amt as dec,crc1 AS INT64,crc2 AS INT64):
      return convAmt(amt,crc1,1,crc2,1,0,0,G-TODAY).
    END.
    METHOD PUBLIC DEC convAmt(amt as dec,crc1 AS INT64,crc2 AS INT64,
                              dat as dat):
      return convAmt(amt,crc1,1,crc2,1,0,0,dat).
    END.
    
    METHOD PUBLIC DEC convAmt(amt as dec,
                              crc1 AS INT64,n1 AS INT64,
                              crc2 AS INT64,n2 AS INT64):
      return convAmt(amt,crc1,n1,crc2,n2,0,0,G-TODAY).
    END.
 
    METHOD PUBLIC DEC convAmt(amt as dec,
                              crc1 AS INT64,n1 AS INT64,
                              crc2 AS INT64,n2 AS INT64,
                              dat as dat):
      return convAmt(amt,crc1,n1,crc2,n2,0,0,dat).
    END.
    METHOD PUBLIC DEC convAmt(iamt AS DEC,
                              crc1 as int64,n1 AS INT64,
                              crc2 as int64,n2 AS INT64,
                              rat1 as dec,  rat2 as dec,
                              dat as DAT):
        return convAmt(iamt,crc1,n1,crc2,n2,rat1,rat2,dat,99999).
    END.
        
    METHOD PUBLIC DEC convAmt(iamt AS DEC,
                              crc1 as int64,n1 AS INT64,
                              crc2 as int64,n2 AS INT64,
                              rat1 as dec,  rat2 as dec,
                              dat  as DAT, tim as INT64):
      def var oamt as dec no-undo.
      if iamt eq 0 then return 0.
      if crc1 eq 0 and crc2 eq 0 and rat1 eq 0 and rat2 eq 0 then return 0.
      if crc1 ne 0 and crc2 ne 0 and (crc1 eq crc2 and rat1 eq rat2)
      then return iamt.
      
      if n1 eq 0 then n1 = 1.
      if n2 eq 0 then n2 = 1.
      if dat eq ? then dat  = G-TODAY.
      
      if rat1 eq 0 then rat1 = Rate(crc1,dat,n1,tim).
      if rat2 eq 0 then rat2 = Rate(crc2,dat,n2,tim).
      if rat1 eq 0 or rat2 eq 0 then return 0.
      if rat1 eq rat2 then return iamt.
      
      if dat < EUR_DT then do:
        oamt = iamt * rat1 / rat2.
      end.
      else do:
        oamt = iamt * rat2 / rat1.
      end.
      if oamt eq ? then oamt = 0.
      return oamt.
    END.
    
    
    
    METHOD PUBLIC VOID fexpRate(crc1 as int64,
                                crc2 as int64,
                                rat1 as dec,
                                rat2 as dec,
                                output crat as dec,
                                output rev as log):
      fexpRate(crc1,crc2,rat1,rat2,G-TODAY,output crat,output rev).
    END.
    METHOD PUBLIC DEC fexpRate(crc1 as int64,
                               crc2 as int64,
                               rat1 as dec,
                               rat2 as dec,
                               dat  as dat,
                               output crat as dec,
                               output rev as log):
      if dat < EUR_DT then crat = rat1 / rat2.
      else do:
        crat = crossRate(crc1,1,crc2,1,rat1,rat2,dat,0).
        rev  = useRevRate(crc1,crc2,rat1,rat2).
      end. 
    END.
    METHOD PUBLIC VOID ratesByFex(fex as cha,
                                  output rat1 AS DEC,
                                  output rat2 AS DEC):
      ratesByFex(fex,yes,output rat1,output rat2).
    END.
    METHOD PUBLIC DEC fexpCrat(fex as cha):
      def var crat as dec no-undo.
      def buffer fexp for bank.fexp.
      find first fexp where fexp.fex = fex no-lock no-error.
      if not avail fexp then return 0.
      crat = dec(fexp.ref) no-error.
      if error-status:error or crat = 0 then crat = fexp.rate.
      return crat.
    END.
    METHOD PUBLIC VOID ratesByFex(fex as cha,
                                  dsp as log,
                                  output rat1 AS DEC,
                                  output rat2 AS DEC):
      def buffer fexp for bank.fexp.
      find first fexp where fexp.fex = fex no-lock no-error.
      if not avail fexp then return.
      
      ratesByCrate(fexp.fcrc,fexp.tcrc,fexpCrat(fex),fexp.ok,fexp.regdt,dsp,
      output rat1,output rat2).
    END.
    
    METHOD PUBLIC VOID ratesByCrate(crc1 as int64,
                                    crc2 as int64,
                                    crat as dec,
                                    rev  as log,
                                    dat  as dat,
                                    dsp  as log,
                                    output rat1 AS DEC,
                                    output rat2 AS DEC):
      def var rat as dec no-undo.
      if dat < EUR_DT then do:
        if crc1 = 1 then do: 
          rat1 = round(1 / crat,6).
          rat2 = 1.
        end.
        else do:
          rat1 = 1.
          rat2 = crat.
        end.
        if not dsp then do:
          rat =  rat1.
          rat1 = rat2.
          rat2 = rat.
        end.
      end.
      else do:
        rat1 = 1.
        rat2 = crat.
        if rev then do:
          rat1 = crat.
          rat2 = 1.
        end.
      end.
    END.
    METHOD PUBLIC log isCnt(cnt as cha):
      def buffer cntfexp for bank.cntfexp.
      find first cntfexp where cntfexp.cnt = cnt no-lock no-error.
      return avail cntfexp.
    END.
    METHOD PUBLIC cha getCnt(fex as cha):
      def var cnt as cha no-undo.
        
      def buffer fexp for bank.fexp.
      def buffer cntfexp for bank.cntfexp.
            
      find first fexp where fexp.fex eq fex no-lock no-error.
      if avail fexp then do:
        find first cntfexp where cntfexp.fex = fexp.fex no-lock no-error.
        if avail cntfexp then cnt = cntfexp.cnt.
      end.
      return cnt.
    END.
    
    METHOD PUBLIC log splitRem(rem as cha,
                               output rem1 as cha,
                               output rat  as dec,
                               output cod1 as cha,
                               output cod2 as cha,
                               output rem2 as cha):
      def var ii as int64 no-undo.
      def var jj as int64 no-undo.
      def var ratcha as cha no-undo.
      def var ratok as log no-undo.
      def var ok as log no-undo.
      
      do ii = 1 to num-entries(rem," "):
        if entry(ii,rem," ") ne "/" then next.
        jj = ii - 2.
        repeat while jj > 0:
          ratcha = entry(jj,rem," ").
          rat = dec(trim(ratcha)) no-error.
          if ratcha ne "" and not error-status:error then do:
            ratok = yes.
            leave.
          end.
          jj = jj - 1.
        end.
        cod1 = entry(ii - 1,rem," ").
        cod2 = entry(ii + 1,rem," ").
        if not ratok or crc(cod1) lt 1 or crc(cod2) lt 1 then next.
        rem1 = trim(substr(rem,1,index(rem,ratcha) - 1)).
        rem2 = trim(substr(rem,index(rem,cod1 + " / " + cod2) + 10)).
        ok = yes.
      end.
      return ok.
    END.
    
    METHOD PUBLIC log fexpAdjust(fex as cha):
      return fexpAdjust(fex,no,0.3).
    END.
    
    METHOD PUBLIC log fexpAdjust(fex as cha,testMode as log):
      return fexpAdjust(fex,testMode,0.3).
    END.
              
    METHOD PUBLIC log fexpAdjust(fex as cha,lim as dec):
      return fexpAdjust(fex,no,0.3).
    END.
              
    METHOD PUBLIC log fexpAdjust(fex as cha,testMode as log,lim as dec):
      def buffer unicat for bank.unicat.
      def var adj as log no-undo.
      def var adjOn as log no-undo init yes.
      def var crat as dec no-undo.
      def var rev  as log no-undo.
      
      def var rem  as cha no-undo.
      def var rem1 as cha no-undo.
      def var rat as dec no-undo.
      def var cod1 as cha no-undo.
      def var cod2 as cha no-undo.
      def var rem2 as cha no-undo.
      
      def var cnt  as cha no-undo.
      def var logStr as cha no-undo.
      def buffer fexp for bank.fexp.
      
      if testMode then adjOn = no.
      else do:
        find first sysc where sysc.sysc eq "FEXP_ADJUSTMENT_ON"
        no-lock no-error.
        if avail sysc then adjOn = sysc.loval.
      end.
      
      find first fexp where fexp.fex = fex no-error.
      if not avail fexp then return no.
      if fexp.fcrc eq crcLvl or fexp.tcrc eq crcLvl then return no.
      
      logStr = string(fexp.rate) + ";" + string(fexp.ok) + ";" + 
      fexp.ref + ";" + fexp.rem + ";".
      
      fexpRate(fexp.fcrc,fexp.tcrc,fexp.amt,fexp.payment,
      output crat,output rev).     
      if fexp.ok ne rev then do:
        adj = yes.
        if adjOn then assign fexp.ok = rev.
      end.   
      if fexp.rate eq 0 or fexp.rate eq ? or
      abs(fexp.rate - crat) > lim * fexp.rate then do:
        adj = yes.
        if adjOn then do:
          assign fexp.rate = crat
                 fexp.ref  = string(crat).
        end.
      end.
        
      rem = fexp.rem.
      if splitRem(rem,output rem1,output rat,output cod1,output cod2,
      output rem2) and (rat eq 0 or abs(rat - crat) > lim * rat) then do:
        rem = convRem(rem1,fexp.fcrc,1,fexp.tcrc,1,
                      fexp.amt,fexp.payment,6,"/",rem2).
                                  
      end.
      
      cnt = getCnt(fex).
      if not rem matches "*. REF :*" and cnt ne "" 
      then do:
        rem = trim(rem).
        if substr(rem,length(rem),1) eq "." 
        then rem = rem + " REF :" + cnt.
        else rem = rem + ". REF :" + cnt.
      end.
      if rem ne fexp.rem then do:
        adj = yes.
        if adjOn then assign fexp.rem  = rem.
      end.
      
      if adj then do:
        if testMode then do: message round(crat,4) rev rem. pause. end.
        create unicat.
        assign unicat.catid  = "FEXP_ADJUST"
               unicat.field1 = fex + " " + string(g-today,"99.99.9999") + " " +
                               string(time,"hh:mm:ss") + " " + (
                               if adjOn then "FIXED" else "TEST")
               unicat.field2 = logStr.
      end.
      
      return adj.
    END.
    
    METHOD PUBLIC DEC convRate(crc1 AS INT64,crc2 AS INT64):
      return convRate(crc1,1,crc2,1,0,0,G-TODAY).
    END.
    METHOD PUBLIC DEC convRate(crc1 AS INT64,crc2 AS INT64,dat as dat):
      return convRate(crc1,1,crc2,1,0,0,dat).
    END.
    
    METHOD PUBLIC DEC convRate(crc1 AS INT64,n1 AS INT64,
                               crc2 AS INT64,n2 AS INT64):
      return convRate(crc1,n1,crc2,n2,0,0,G-TODAY).
    END.
 
    METHOD PUBLIC DEC convRate(crc1 AS INT64,n1 AS INT64,
                               crc2 AS INT64,n2 AS INT64,dat as dat):
      return convRate(crc1,n1,crc2,n2,0,0,dat).
    END.
    METHOD PUBLIC DEC convRate(crc1 as int64,n1 AS INT64,
                               crc2 as int64,n2 AS INT64,
                               rat1 as dec,  rat2 as dec):
      return convRate(crc1,n1,crc2,n2,rat1,rat2,G-TODAY).
    END.
    
 
    METHOD PUBLIC DEC convRate(crc1 as int64,n1 AS INT64,
                               crc2 as int64,n2 AS INT64,
                               rat1 as dec,  rat2 as dec,
                               dat as dat):
      return convAmt(1,crc1,n1,crc2,n2,rat1,rat2,dat).
    END.
    METHOD PUBLIC log useRevRate(crc1 as int64,crc2 as int64,
                                 rat1 as dec  ,rat2 as dec):
      RETURN useRevRate(crc1,crc2,rat1,rat2,G-TODAY).
    END.
    
    METHOD PUBLIC log useRevRate(crc1 as int64,crc2 as int64,
                                 rat1 as dec  ,rat2 as dec,
                                 dat  as dat):
      def var rev as log no-undo.
      if isInCrcWeight(crc1) or isInCrcWeight(crc2) then do:
        if getCrcWeight(crc1) < getCrcWeight(crc2) then rev = true.
      end.
      else do:
        if dat < EUR_DT then do:
          if rat1 < rat2 then rev = true.
        end.
        else do:
          if rat1 > rat2 then rev = true.
        end.
      end.
      return rev.                                  
    END.
    METHOD PUBLIC int64 getCrcWeight(crc as int64):
      return getCrcWeight(crc,G-TODAY).
    END.
    METHOD PUBLIC int64 getCrcWeight(crc as int64,dat as dat):
      case crc.
      when  1 then return -1.
      when  2 then return 1.
      when 29 then return 2.
      when  6 then return 3.
      when 15 then return 4.
      when 11 then return 5.
      when 44 then return 6.
      otherwise return 0.
      end case.
    END.
    
    METHOD PUBLIC LOG isInCrcWeight(crc as int64):
      return isInCrcWeight(crc,G-TODAY).
    END.
    
    METHOD PUBLIC LOG isInCrcWeight(crc as int64,dat as dat):
      if getCrcWeight(crc,dat) <> 0 
      then return yes.
      else return no.
    END.
    
    METHOD PUBLIC int64 sortCrcByWeight(crc1 as int64,crc2 as int64):
      RETURN sortCrcByWeight(crc1,crc2,G-TODAY).
    END.
    
    METHOD PUBLIC int64 sortCrcByWeight(crc1 as int64,
                                           crc2 as int64,dat as dat):
      return if getCrcWeight(crc1,dat) < getCrcWeight(crc2,dat)
      then crc1 else crc2.
    END.
    
    METHOD PUBLIC cha rateDsp(crc1 as int64):
      RETURN rateDsp(crc1,?,0,0,0,no,"").
    END.
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat):
      RETURN rateDsp(crc1,dat,0,0,0,no,"").
    END.
    METHOD PUBLIC cha rateDsp(crc1 as int64,n1 as int64):
      RETURN rateDsp(crc1,?,n1,0,0,no,"").
    END.
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat,n1 as int64):
      RETURN rateDsp(crc1,dat,n1,0,0,no,"").
    END.
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat,
                              n1   as int64,dec as int):
      RETURN rateDsp(crc1,dat,n1,dec,0,no,"").
    END.    
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat,
                              n1   as int64,dec as int,
                              mdec as int):
      RETURN rateDsp(crc1,dat,n1,dec,mdec,no,"").
    END.
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat,
                              n1   as int64,dec as int,
                              mdec as int,  rev  as log):
       RETURN rateDsp(crc1,dat,n1,dec,mdec,rev,"").
    END.
    
    METHOD PUBLIC cha rateDsp(crc1 as int64,dat as dat,
                              n1   as int64,dec as int,
                              mdec as int,  rev as log,
                              sep  as cha):
      def var rat  as cha no-undo.
      def var rat1 as dec no-undo.
      def var cd1  as cha no-undo.
      def var cd2  as cha no-undo.
      
      if dat eq ? then dat = G-TODAY.
      if n1 le 0 or n1 gt 7 then n1 = 1.
      if dec eq 0 then dec = 10.
      if mdec eq 0 then mdec = 2.
      if sep eq "" then sep = "/".
      
      cd1 = ccy(crc1).
      if cd1 eq "" then return "N/A".
      cd2 = baseCcy(dat).
      
      rat1 = Rate(crc1,dat,n1).
      if rev then do:
        rat1 = 1 / rat1.
        if rat1 = ? then rat1 = 0.
      end.
      rat1 = round(rat1,dec).
      
      rat = formatRate(rat1,mdec).
      if baseCrc(dat) eq crcEur then rev = not rev.
      if rev then do:
        rat = rat + " " + cd1 + " " + sep + " " + cd2.
      end.
      else do:
        rat = rat + " " + cd2 + " " + sep + " " + cd1.
      end.
      return rat.
    END.
    
    METHOD PUBLIC cha convRem(des as cha,
                              crc1   as int64,n1   as int64,
                              crc2   as int64,n2   as int64,
                              rat1   as dec,  rat2 as dec,
                              dec    as int,  sep  as cha,
                              cntfx1 as cha):
      return convRem(des,crc1,n1,crc2,n2,rat1,rat2,G-TODAY,dec,sep,cntfx1).
    END.
    METHOD PUBLIC cha convRem(des as cha,
                              crc1   as int64,n1   as int64,
                              crc2   as int64,n2   as int64,
                              rat1   as dec,  rat2 as dec,
                              dat    as dat,  dec  as int,
                              sep    as cha,  cnt  as cha):
      def var rem as cha no-undo.
      if des ne "" and index(des, "[[") < 1 then rem = "[[" + des + "]] ". else rem = des + " ".
      rem = rem + crossRateDsp(crc1,n1,crc2,n2,rat1,rat2,dat,dec,sep).
      if cnt ne "" then do:
        if isCnt(cnt) then rem = rem + ". [[REF]] :" + cnt.
        else if cnt matches "*. REF :*" then rem = rem + trim(cnt).
        else rem = rem + " " + cnt.
      end.
      return rem.
    END.    
    METHOD PUBLIC cha cntRef(cnt as cha):
      if cnt ne "" then return ". REF :" + cnt.
      else return "".
    END.
    
    METHOD PUBLIC cha crossRateDsp(crc1 as int64,n1   as int64,
                                   crc2 as int64,n2   as int64,
                                   rat1 as dec,  rat2 as dec,
                                   dec  as int,  sep  as cha):
      return crossRateDsp(crc1,n1,crc2,n2,rat1,rat2,G-TODAY,dec,sep).
    END.
    METHOD PUBLIC cha crossRateDsp(crc1 as int64,n1   as int64,
                                   crc2 as int64,n2   as int64,
                                   rat1 as dec,  rat2 as dec,
                                   dat  as dat,  dec  as int,
                                   sep  as cha):
      def var rat as cha no-undo.
      def var rev as log no-undo.
      def var cd1 as cha no-undo.
      def var cd2 as cha no-undo.
      
      cd1 = LvlToLs(crc1).
      cd2 = LvlToLs(crc2).
      
      if rat1 = 0 then rat1 = Rate(crc1,dat,n1).
      if rat2 = 0 then rat2 = Rate(crc2,dat,n2).
      
      rev = useRevRate(crc1,crc2,rat1,rat2).
      rat = formatRate(crossRate(crc1,n1,crc2,n2,rat1,rat2,dat,dec),2).
      if rev then do:
        if sep ne "" then 
        rat = rat + " " + cd1 + " " + sep + " " + cd2.
      end.
      else do:
        if sep ne "" then 
        rat = rat + " " + cd2 + " " + sep + " " + cd1.
      end.
      return rat.
    END.
    
    METHOD PUBLIC cha formatRate(rat as dec):
      return formatRate(rat,0).
    END.
    METHOD PUBLIC cha formatRate(rat as dec,mindec as int64):
      def var str  as cha no-undo.
      def var str1 as cha no-undo.
      def var str2 as cha no-undo.
      def var ii   as int64 no-undo.
      if mindec < 0 or mindec > 10 then mindec = 0.
      str  = trim(string(rat,">>>,>>>,>>9.<<<<<<<<<<")).
      str1 = entry(1,str,".").
      str2 = entry(2,str,".").
      do ii = 1 to mindec:
        if substr(str2,ii,1) = "" then do:
          str2 = str2 + "0".
        end.
      end.
      if str2 eq "" then return str1. else return str1 + "." + str2.
    END.              
         
    METHOD PUBLIC dec crossRate(crc1 as int64,n1 as int64,
                                crc2 as int64,n2 as int64):
      return crossRate(crc1,n1,crc2,n2,0,0,G-TODAY,0). 
    END.
    
    METHOD PUBLIC dec crossRate(crc1 as int64,n1   as int64,
                                crc2 as int64,n2   as int64,
                                rat1 as dec,  rat2 as dec,
                                dec  as int):
      return crossRate(crc1,n1,crc2,n2,rat1,rat2,G-TODAY,dec).                     END.    
    
    METHOD PUBLIC dec crossRate(crc1 as int64,n1   as int64,
                                crc2 as int64,n2   as int64,
                                rat1 as dec,  rat2 as dec,
                                dat  as dat,  dec  as int):
      def var rat as dec no-undo.
      def var rev as log no-undo.
      
      if dec = 0 then dec = 10.      
      if rat1 = 0 then rat1 = Rate(crc1,dat,n1).
      if rat2 = 0 then rat2 = Rate(crc2,dat,n2).
      rev = useRevRate(crc1,crc2,rat1,rat2).
      if dat < EUR_DT then do:
        if rev then do:
          rat = round(rat2 / rat1,dec).
        end.
        else do:
          rat = round(rat1 / rat2,dec).
        end.
      end.
      else do:
        if rev then do:
          rat = round(rat1 / rat2,dec).
        end.
        else do:
          rat = round(rat2 / rat1,dec).
        end.
      end.
      if rat = ? then rat = 0.
      return rat.
    END.
    METHOD PUBLIC VOID revRate(crc1 AS INT64,
                               crc2 AS INT64,
                               input-output rat1 as dec,
                               input-output rat2 as dec):
      revRate(crc1,crc2,input-output rat1,input-output rat2,G-TODAY).
    END.                                                              
    
    METHOD PUBLIC VOID revRate(crc1 AS INT64,
                               crc2 AS INT64,
                               input-output rat1 as dec,
                               input-output rat2 as dec,
                               dat as dat):
      if dat < EUR_DT then do:
        if useRevRate(crc1,crc2,rat1,rat2,dat) then do:
          rat2 = round(rat2 / rat1,8).
          rat1 = 1.
        end.
        else do:
          rat1 = round(rat1 / rat2,8).
          rat2 = 1.
        end.
      end.
      else do:
        if useRevRate(crc1,crc2,rat1,rat2,dat) then do:
          rat2 = round(rat1 / rat2,8).
          rat1 = 1.
        end.
        else do:
          rat1 = round(rat2 / rat1,8).
          rat2 = 1.
        end.
      end.
    END.
    METHOD PUBLIC LOG smallAmt(amt as dec,crc as int64):
      if Amt(amt,crc) < limamt then return true.
      return false.
    END.
    METHOD PUBLIC DEC LsToEur(crc as int64,amt as dec):
      return LsToEur(crc,amt,G-TODAY).
    END.
    
    METHOD PUBLIC DEC LsToEur(crc as int64,amt as dec,dat as dat):
      if dat lt EUR_DT or crc ne crcLvl then return amt.
      return round(amt / EUR_RATE,2).
    END.
    
    method public dec RoundAmt(amt as dec , crc as inte):
        def buffer crc for bank.crc.
        find crc where crc.crc = crc no-lock no-error.
        if available crc then
            return round(amt , crc.decpnt).
        else
            return amt.
    end.
    
    method public dec RoundAmt(amt as dec , crc as int64):
        return RoundAmt(amt , int(crc)).
    end.
    
    METHOD PUBLIC cha LsToLvl(crc as int64):
      return LsToLvl(Ccy(crc)).
    END.
    METHOD PUBLIC cha LsToLvl(ccy as cha):
      return if ccy = 'Ls' or ccy = "LVL" then "LVL" else ccy.
    END.
    
    METHOD PUBLIC cha LvlToLs(crc as int64):
      return LvlToLs(Ccy(crc)).
    END.
                
    METHOD PUBLIC cha LvlToLs(ccy as cha):
      if ccy = 'BYR' THEN ccy = 'BYN'.
      return if ccy = 'LVL' or ccy = "Ls" then "LVL" else ccy.
    END.
    METHOD PUBLIC log noFee(crc1 as int64,crc2 as int64):
      RETURN noFee(crc1,crc2,G-TODAY).
    END.
    
    METHOD PUBLIC log noFee(crc1 as int64,crc2 as int64,dat as dat):
      def buffer sysc for bank.sysc.
      def var dat1 as dat no-undo.
      def var dat2 as dat no-undo.
      if crc1 ne 1 or crc2 ne 11 then return no.
      dat1 = date(01.01.2014).
      dat2 = date(06.30.2014).
      find first sysc where sysc.sysc = 'noFeeDat1' no-lock no-error.
      if avail sysc and sysc.daval ne ? then dat1 = sysc.daval.
      find first sysc where sysc.sysc = 'noFeeDat2' no-lock no-error.
      if avail sysc and sysc.daval ne ? then dat2 = sysc.daval.
      if dat ge dat1 and dat le dat2 then return yes.
      return no.
    END.
    
    METHOD PUBLIC dec FeeLVLToEUR(crc1 as int64,crc2 as int64,fee as dec):
      if crc1 eq 1 and crc2 eq 11 then do:
        if noFee(crc1,crc2,g-today) then fee = 0.0.
        /*else run cm_fxbr.p(1,output fee).*/
      end.
      return fee.
    END.
    METHOD PUBLIC dec RatN(crc as int64):
      return RatN(crc,G-TODAY,1).
    END.
    METHOD PUBLIC dec RatN(crc as int64,typ as int64):
      return RatN(crc,G-TODAY,typ).
    END.
    
    METHOD PUBLIC dec RatN(crc as int64,dat as dat,typ as int64):
      def var rat as dec no-undo.
      def buffer crchis for bank.crchis.
      find last crchis where crchis.crc eq crc and crchis.rdt le dat
      no-lock no-error.
      if avail crchis then do:
        if dat ge EUR_DT and crchis.rdt lt EUR_DT then rat = 0.
        else rat = crchis.rate[typ].
      end.
      if rat eq ? then rat = 0.
      return rat.
    END.
        
    METHOD PUBLIC CHAR Ccy_replace(f_Crc AS CHAR):
      IF f_Crc = "Ls" THEN f_Crc = "LVL".
        /*ELSE IF f_Crc = "RUR" THEN f_Crc = "RUB".*/
        /*ELSE IF f_Crc = "BYB" THEN f_Crc = "BYR".*/
      RETURN f_Crc.
    END.
       
    /*
        Метод предназначен для получение курса валюты LB/ECB для отображения в списках валют
        Входные параметры: f_Crc, f_Dt - валюта и дата курса
        Выходные: Rate - курс валюты, Rate9 - за количество единиц.
                  f_Ccy - код валюты, f_Des - название ваоюты.
                Усли значение метода меньше нуля, то курс не найден.
    */
    
    METHOD PUBLIC INT Get_Display_Rates(f_Crc AS INT64, f_Dt AS DATE, 
                                        OUTPUT Rate AS DEC, OUTPUT Rate9 AS DEC, 
                                        OUTPUT f_Ccy AS CHAR, OUTPUT f_Des AS CHAR):
        DEF VAR Rate8 AS DEC NO-UNDO.
        DEF BUFFER crchis FOR bank.crchis.
        FIND LAST crchis where crchis.crc = f_Crc and crchis.rdt le f_Dt no-lock no-error.
        IF NOT AVAILABLE crchis THEN RETURN -1.
        Rate  = crchis.rate[1].
        IF Rate <= 0 then RETURN -2.
        Rate9 = crchis.rate[9].
        IF f_Dt < EUR_DT THEN 
         DO:
            Rate = Rate.
            Rate8 = crchis.rate[8].
            IF Rate8 ne 0 and Rate9 > 999 THEN
             DO: Rate = Rate / 1000. Rate9 = Rate9 / 1000. END.
         END.
        ELSE 
         DO:
            IF Rate = 100 THEN DO: Rate = 1. Rate9 = Rate9 / 100. END.
            Rate8 = Rate.
            Rate  = Rate9.
            Rate9 = Rate8.
            Rate8 = 0. 
         END.
         RETURN 0.
    END.
    METHOD PUBLIC INT64 AccCrc(Acc AS CHAR):
        RETURN AccCrc(Acc,"",g-today).
    END.
        
    METHOD PUBLIC INT64 AccCrc(Acc AS CHAR,Dat AS DATE):
        RETURN AccCrc(Acc,"",Dat).
    END.
    
    METHOD PUBLIC INT64 AccCrc(Acc AS CHAR,Tab AS CHAR):
        RETURN AccCrc(Acc,Tab,g-today).
    END.
                                    
    METHOD PUBLIC INT64 AccCrc(Acc AS CHAR,
                               Tab AS CHAR,
                               Dat AS DATE):
        DEF BUFFER lon FOR bank.lon.
        DEF BUFFER aaa FOR bank.aaa.
        DEF BUFFER arp FOR bank.arp.
        DEFINE VARIABLE Crc AS INT64.
        IF Acc EQ "" THEN RETURN 0.
        
        IF dat EQ g-today THEN DO:
            CASE Tab:
                WHEN "lon" THEN DO:
                    FIND FIRST lon WHERE lon.lon EQ Acc NO-LOCK NO-ERROR.
                    IF AVAILABLE lon THEN Crc = lon.crc.
                END.
                WHEN "aaa" THEN DO:
                    FIND FIRST aaa WHERE aaa.aaa EQ Acc NO-LOCK NO-ERROR.
                    IF AVAILABLE aaa THEN Crc = aaa.crc.
                END.
                WHEN "arp" THEN DO:
                    FIND FIRST arp WHERE arp.arp EQ Acc NO-LOCK NO-ERROR.
                    IF AVAILABLE arp THEN Crc = arp.crc.
                END.
                OTHERWISE DO:
                    FIND FIRST lon WHERE lon.lon EQ Acc NO-LOCK NO-ERROR.
                    IF AVAILABLE lon THEN Crc = lon.crc.
                    ELSE DO:
                        FIND FIRST aaa WHERE aaa.aaa EQ Acc NO-LOCK NO-ERROR.
                        IF AVAILABLE aaa THEN Crc = aaa.crc.
                        ELSE DO:
                            FIND FIRST arp WHERE arp.arp EQ Acc 
                            NO-LOCK NO-ERROR.
                            IF AVAILABLE arp THEN Crc = arp.crc.
                        END.
                    END.
                END.
            END CASE.
        END.
        ELSE DO:
            DEF BUFFER aab for bank.aab.
            FIND LAST aab WHERE aab.aaa EQ Acc AND aab.fdt LE Dat 
            NO-LOCK NO-ERROR.
            Crc = IF AVAILABLE aab THEN aab.crc ELSE 0.
        END.
        
        RETURN Crc.
    END.
    
/*
    METHOD PUBLIC LOG EcbcrossRateDsp(fromCrc AS INT64,toCrc AS INT64):
      if fromCrc = 1 or (toCrc = 2 and fromCrc ne 11 and fromCrc ne 15)
      or toCrc eq 11 or toCrc eq 15 
        then return true.
        else return false.
    END.
*/    
    
    METHOD PUBLIC INT Example():
        DEF VAR ccrc AS syscrc NO-UNDO.
        ccrc = NEW syscrc().
        
        /* Получить цифровой код национальной валюты на дату    */
        disp ccrc:BaseCrc(today + 400)            FORMAT ">>9".
        /* Цифровой код национальной валюты на g-today           */
        disp ccrc:BaseCrc()                       FORMAT ">>9".
        /* Получить буквенный код национальной валюты на дату    */
        disp ccrc:BaseCcy(today + 400)            FORMAT "XXX".
        /* Получить буквенный код национальной валюты на g-today */
        disp ccrc:BaseCcy()                       FORMAT "XXX".
        /* Преобразование типов кодов валют */
        /* Числовой код в буквенный */
        disp ccrc:Ccy(44).
        /* Буквенный в числовой     */
        disp ccrc:Crc("XAU").
    
        /* Курс валюты на дату (по числовому коду валюты) */
        disp ccrc:Rate(11, today - 10)    FORMAT "->>>9.999999".
        /* Курс валюты на дату (по буквенному коду валюты) */
        disp ccrc:Rate("USD", today - 20) FORMAT "->>>9.999999".
        /* Курс валюты на g-today (по числовому коду валюты) */
        disp ccrc:Rate(11)                FORMAT "->>>9.999999".
        /* Курс валюты на g-today (по буквенному коду валюты) */
        disp ccrc:Rate("USD")             FORMAT "->>>9.999999".
        DELETE OBJECT ccrc NO-ERROR.
    END. 
    
    
    
END CLASS.
