/* Main procedure for creating jl */

define input parameter trx_numb    AS int64.
define input parameter jl_glkon    AS int64.
define input parameter jl_account  AS character.
define input parameter jl_line     AS int64.
define input parameter jl_debet    AS dec.
define input parameter jl_credit   AS dec.
define input parameter jl_rem1     AS char.
define input parameter jl_rem2     AS char.
define input parameter jl_rem3     AS char.
define input parameter jl_oprtype    AS char.
define input parameter jl_currency AS int64.
define input parameter jl_dat      AS date.
define input parameter jl_ofc      AS char.

define input parameter opcod as int64.
define input parameter fltkey as log.
define input parameter nchkaaccbalanceal as log.
define input parameter nchkarpbal as log.
define input parameter chkacc as log.
define input parameter nchgbal as log.
define input parameter trxnum as int64.
define input parameter trx_status as int64.
define input parameter trx_authorize as char.
define output parameter sost as int64.
define output parameter mes as character format "x(75)".

define variable x_ah4 like aah.aah initial 0.
define buffer baaa for aaa.
define buffer barp for arp.
define buffer fb_gl for gl.
define variable tem like jl.bal.
define variable ost like jl.bal.
define variable os_t like jl.bal.
define variable ah_numb like aah.aah.
define variable krkon like aaa.aaa.
define variable rm1  as character.
define variable rm2  as character.
define variable rm3  as character.
def var ms1          as char init
    "Balance account in TRX differs from balance account in SubAccount!".
def var ms2          as char init
    "Currency in TRX differs from currency in SubAccount!".
def var msnbal as char.
def var opcd like aal.aax.
def var odnot as char.
def var checkSD as log init yes. /* by ingsaf */
def var checkSK as log init yes. 
def var checkDEAKT as log init yes.
def var canDrCard as log init no.
def var nodeaktcheck as char.
def var mysum as decimal.
def var euro_convert as log init no.
def var orig_lin like jl.ln.
def var t_Rem_Template as char no-undo.
def var rem4      as char no-undo. /* Pustyshka dlja sovmestimosti v [mak_template.p] */
{global.i}

 
def var f_CIF    as char no-undo.
def var f_Subled as char no-undo.

if g-fname ne "" then do: 
    find first unicat where unicat.catid eq "NOSDCHECK-FNAME" and unicat.field1 eq g-fname no-lock no-error.
    if available unicat then checkSD = false.
end.
if g-fname ne "" then do: 
    find first unicat where unicat.catid eq "NOSKCHECK-FNAME" and unicat.field1 eq g-fname no-lock no-error.
    if available unicat then checkSK = false.
END.

FUNCTION setError LOG (iSost AS INT64, iMess AS CHAR):
    Sost = iSost.
    mes = iMess.
    RETURN false.
END.
FUNCTION isValidCurrency LOG(currency AS INT64):
    DEFINE BUFFER bf_crc FOR crc.
    find bf_crc where bf_crc.crc = currency no-lock no-error.
    if not available bf_crc then do:
        setError(0, "Currency " + string(currency) +  " is incorrect!").
        return false.
    end. 
    return true.
END.
FUNCTION isValidGlAccount LOG(iGl AS INT64):
    def buffer gl for bank.gl.
    find gl where gl.gl = iGl no-lock no-error.
    if not available gl then do:
        setError(0, "Balance account " + string(iGl, ">>>>>9") +  " is incorrect!").
        return false.
    end.
    if gl.restrict_operation eq YES then do:
        setError(0, "Balance account " + string(iGl, ">>>>>9") + " is closed for operations!").
        return false.
    end.
    return true.
 END.
 
 FUNCTION isValidTrxNumber LOG(trx_numb AS INT64):
    find FIRST jh WHERE jh.jh = trx_numb no-lock no-error.
    if not available jh then do:
        setError(0, "Incorrect Transaction Number " + string(trx_numb) +  " !").
        return false.
    end.
    return true.
 END.
 
 FUNCTION trx_line_check INT64(trx_numb AS INT64, trx_line AS INT64):
    find first jl where jl.jh = trx_numb and jl.ln = trx_line use-index jhln
    no-lock no-error.
    if available jl then do :
        find last jl where jl.jh = numb use-index jhln no-lock no-error.
        if available jl then trx_line = jl.ln + 1.
    end.  
    RETURN trx_line.
 END.
 
 FUNCTION isValidTrxDate LOG(trx_dat AS date):
    find FIRST cls WHERE cls.cls = trx_dat no-lock no-error.
    if not available cls then do:
        IF trx_dat = TODAY THEN DO:
            RUN open_new_balance_date(trx_dat). /* TODO !!!!! cls create, glday create */
            RETURN TRUE.
        END.
        setError(0, "Incorrect Transaction Date " + string(trx_dat) +  " !").
        return false.
    end.
    ELSE IF cls.closed = YES THEN DO:
        setError(0, "Date is closed for operations " + string(trx_dat) +  " !").
        return false.
    END.
    return true.
    /* TODO Нужен процесс автоматического создания cls, glday, когда наступает новая дата */
 END.
 
/*  Надо подумать, что с этим делать 
define variable tRem1  as character.
define variable tRem2  as character.
define variable tRem3  as character.
define variable tRem4  as character.
tRem1 = rem1. tRem2 = rem2. tRem3 = rem3. tRem4 = rem4.
RUN mak_template.r(INPUT-OUTPUT tRem1, INPUT-OUTPUT tRem2, INPUT-OUTPUT tRem3,INPUT-OUTPUT tRem4, OUTPUT t_Rem_Template).
*/

do transaction :
    sost = 0.
    IF isValidTrxNumber(trx_numb) = NO THEN RETURN.
    FIND FIRST jh WHERE jh.jh = trx_numb EXCLUSIVE-LOCK NO-ERROR.
    
    jl_line = trx_line_check(trx_numb,jl_line).
    
    IF isValidGlAccount(jl_glkon) = NO THEN RETURN.
    find gl where gl.gl = jl_glkon NO-LOCK NO-ERROR.
    
    IF isValidCurrency(jl_currency) = NO THEN RETURN.
    find crc where crc.crc = jl_currency no-lock no-error.
    if available crc then do :
        jl_debet = round(jl_debet,crc.decpnt).
        jl_credit = round(jl_credit,crc.decpnt).
    end.
    else do :
        jl_debet = round(jl_debet,2).
        jl_credit = round(jl_credit,2).
    end.    
    
    IF isValidGlAccount(jl_dat) = NO THEN RETURN.
    
    IF gl.subled NE "" THEN DO:
        run ValidateSubacc(jl_account, jl_oprtype, OUTPUT odaccount, OUTPUT isOK, OUTPUT mes). 
        IF isok = NO THEN RETURN.
        FIND FIRST subacc WHERE subacc.account = jl_account EXCLUSIVE-LOCK NO-ERROR.
        jl_cif = subacc.cif.
        RUN calc_balance(subacc.account,subacc.odaccount, subacc.gl, subacc.crc, jl_dat, OUTPUT isok, OUTPUT mes, 
        OUTPUT account_balance).
        IF isok = NO THEN RETURN.
        IF nocheckbalance = NO THEN DO:
            RUN chk_balance(jl_account,account_balance, gl.type, jl_oprtype, jl_debet, jl_credit, OUTPUT isok, OUTPUT mes).
        END.
        ELSE isok = YES.
        IF isok = NO THEN RETURN.   
        RUN make_jl_line().
        RUN if_need_od_line(OUTPUT need_od_line).
    
        IF need_od_line = YES THEN DO:
            make_od_line().
        END.
        /* Это признак того, что надо накатывать остаток сразу */
        IF change_balance_sign = YES THEN RUN change_gl_balance().
        ELSE RUN create_future_gl_balance().
        IF change_balance_sign = YES THEN RUN change_account_balance(jl_account, gl.subled, jl_oprtype).
        ELSE create_future_account_balance().
        IF change_balance_sign = YES THEN RUN change_info_account().
    END.
    ELSE DO:
        isok = YES.
        IF change_balance_sign = YES THEN RUN change_gl_balance().
    END.
    
    /* Надо подумать, делать ли овердрафтные линии 
    по каждой транзакции или одну результирующую линию в конце дня 
    
    Также надо подумать об автоматическом накате остатков по субсчетам - делать это отдельным
    процессом, а не в самой транзакции */
end.

procedure ValidateSubacc : 
    DEFINE INPUT PARAMETER subacc AS CHARACTER. 
    DEFINE INPUT PARAMETER opr_type AS CHARACTER.
    DEFINE OUTPUT PARAMETER odaccount AS CHARACTER.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    DEFINE OUTPUT PARAMETER Errmes AS CHARACTER.
    
    DEFINE BUFFER bf_subacc FOR subacc.
    
    OK = NO.
    find first subacc where subacc.account = subacc exclusive-lock no-error.
    if avail subacc and opr_type = "D" then do:
        find first aas where aas.account = subacc.account no-lock no-error. 
        if avail aas and checkSD then do:
            Errmes = " Stop Debet instruction for " + subacc +  " " + aas.reason.
            return .
        end.
    end.    
    else if avail subacc and opr_type = "C" then do:
        find first aas where aas.account = subacc.account no-lock no-error. 
        if avail aas and checkSK then do:
            Errmes = " Stop Credit instruction for " + subacc +  " " + aas.reason.
            return .
        end.
    end.
    if subacc.gl ne glkon then do :
        Errmes = ms1.
        return.
    end.
    if subacc.crc ne val then do :
        Errmes = ms2.
        return.
    end. 
    IF subacc.odaccount NE "" THEN DO:
        odaccount = subacc.odaccount.
        find first bf_subacc where bf_subacc.account = odaccount exclusive-lock no-error.
    end.    
        
    OK = YES.
    
END PROCEDURE. 

PROCEDURE calc_balance :
    DEFINE INPUT PARAMETER account AS CHARACTER.
    DEFINE INPUT PARAMETER odaccount AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl AS INT64.
    DEFINE INPUT PARAMETER account_crc AS INT64.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE OUTPUT PARAMETER ok AS LOG.
    DEFINE OUTPUT PARAMETER ErrMes AS CHARACTER.
    DEFINE OUTPUT PARAMETER account_balance AS dec.
    
    DEFINE BUFFER bf_accbalance FOR accbalance.
    DEFINE BUFFER bf_subacc FOR subacc.
    
    DEFINE VARIABLE acc_future_balance AS DECIMAL.
    DEFINE VARIABLE odacc_future_balance AS DECIMAL.
    DEFINE VARIABLE okbal AS LOG INITIAL NO.
    
    OK = NO.
    FIND FIRST accbalance WHERE accbalance.account = account AND 
    accbalance.cbalancedate EQ opr_date EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE accbalance THEN DO:
        RUN create_accbalance(account,account_gl, account_crc, opr_date,OUTPUT okbal).
        IF okbal = NO THEN DO:
            ErrMes = "Can't calculate Account Balance!".
            RETURN.
        END.    
        FIND FIRST accbalance WHERE accbalance.account = account AND 
        accbalance.cbalancedate EQ opr_date EXCLUSIVE-LOCK NO-ERROR.
    END.
    account_balance = accbalance.cbalance - accbalance.hold.
    RUN calc_future_balance(account, OUTPUT acc_future_balance).
    account_balance = account_balance + acc_future_balance.
    IF odaccount NE "" THEN DO:
        FIND FIRST bf_subacc WHERE bf_subacc.account = odaccount EXCLUSIVE-LOCK NO-ERROR.
        FIND FIRST bf_accbalance WHERE bf_accbalance.account = odaccount AND 
        bf_accbalance.cbalancedate EQ opr_date EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE bf_accbalance THEN DO:
            RUN create_accbalance(odaccount, bf_subacc.gl, bf_subacc.crc, opr_date,OUTPUT okbal).
            IF okbal = NO THEN DO:
                ErrMes = "Can't calculate O/D Account Balance!".
                RETURN.
            END.    
            FIND FIRST bf_accbalance WHERE bf_accbalance.account = odaccount AND 
            bf_accbalance.cbalancedate EQ opr_date EXCLUSIVE-LOCK NO-ERROR.
        END.
        account_balance = account_balance + (bf_accbalance.cbalance - bf_accbalance.hold).
        RUN calc_future_balance(odaccount, OUTPUT odacc_future_balance).
        account_balance = account_balance + odacc_future_balance.
    END.
END PROCEDURE.


PROCEDURE create_accbalance :
    DEFINE INPUT PARAMETER account     AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl  AS INT64.
    DEFINE INPUT PARAMETER account_crc AS int64.
    DEFINE INPUT PARAMETER opr_date    AS DATE.
    DEFINE OUTPUT PARAMETER ok         AS LOG.
    DEFINE BUFFER bf_accbalance FOR accbalance.
    
    FIND last bf_accbalance WHERE bf_accbalance.account = account AND 
    bf_accbalance.cbalancedate lt opr_date EXCLUSIVE-LOCK NO-ERROR. 
    IF AVAILABLE bf_accbalance THEN DO:
        CREATE accbalance.
        BUFFER-COPY bf_accbalance TO accbalance.
        accbalance.cbalancedat = opr_date.
        /* Trigger na whn */
    END.
    ELSE DO:
        create accbalance.
        assign
            accbalance.account = account
            accbalance.gl      = account_gl
            accbalance.cbalancedate = opr_date
            accbalance.crc     = account_crc.
            /* Trigger na whn */
    END.
    ok = YES.
END PROCEDURE.

PROCEDURE check_balance :
    DEFINE INPUT PARAMETER account AS CHARACTER.
    DEFINE INPUT PARAMETER account_balance AS DECIMAL.
    DEFINE INPUT PARAMETER gltype AS CHARACTER.
    DEFINE INPUT PARAMETER opr_type AS CHARACTER.
    DEFINE INPUT PARAMETER debet AS DECIMAL.
    DEFINE INPUT PARAMETER credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    DEFINE OUTPUT PARAMETER Errmes AS CHARACTER.
    
    OK = NO.
    
    IF ((gl_type = "A" OR gl_type = "E") AND opr_type = "D") OR 
       ((gl_type = "L" OR gl_type = "O") AND opr_type = "C") THEN DO:
        OK = YES.
        RETURN.
    END.
    IF ((gl_type = "A" OR gl_type = "E") AND opr_type = "C" AND account_balance GE credit) OR
       ((gl_type = "L" OR gl_type = "O") AND opr_type = "D" AND account_balance GE debet) THEN DO:
       OK = YES.
       RETURN.
    END.  
    Errmes = "Out of balance on Account " + account + "!".
END PROCEDURE.

PROCEDURE make_jl_line:
    create jl.
    assign jl.jh     = trx_numb 
           jl.gl     = jl_glkon 
           jl.acc    = jl_account 
           jl.dam    = jl_debet 
           jl.cam    = jl_credit 
           jl.who    = jl_ofc 
           jl.whn    = today 
           jl.tim    = time
           jl.ln     = jl_line 
           jl.jdt    = jl_dat 
           jl.rem[1] = jl_rem1 
           jl.rem[2] = jl_rem2 
           jl.rem[3] = jl_rem3 
           /* ??? jl.rem_template = t_Rem_Template */
           jl.dc     = jl_oprtype 
           jl.crc    = jl_currency
           jl.sts    = jl_status
           jl.teller = jl_authorize
           jl.cif    = jl_cif. 
END PROCEDURE.

PROCEDURE change_account_balance():
    OK = NO.
    /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
    FOR EACH accbalance WHERE accbalance.account = account AND 
        accbalance.cbalancedate ge opr_date EXCLUSIVE-LOCK :
        assign
            accbalance.total_debet = accbalance.total_debet + jl_debet
            accbalance.total_credit = accbalance.total_credit + jl_credit.
        
        IF opr_type = "D" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN accbalance.cbalance = accbalance.cbalance + jl_debet.
            ELSE IF (gl_type = "L" OR gl_type = "O") then accbalance.cbalance = accbalance.cbalance - jl_debet.
        END. 
        ELSE IF opr_type = "C" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN accbalance.cbalance = accbalance.cbalance - jl_credit.
            ELSE IF (gl_type = "L" OR gl_type = "O") THEN DO:
                IF gl_subled = "CIF" THEN DO:
                    if floatkey = YES THEN accbalance.floatbal = accbalance.floatbal + jl_credit.
                    ELSE accbalance.cbalance = accbalance.cbalance + jl_credit.
                END.
                ELSE accbalance.cbalance = accbalance.cbalance + jl_credit.
            END.             
        END.
        accbalance.availbal = accbalance.cbalance - accbalance.holdbal.
    END.    
    OK = YES.
END PROCEDURE.

               
procedure create_future_balance:
  /* sozdanije linij dlja posledujushchego nakata v schjot */
  if g-fname begins "DAYCLS" then leave.
  find first fb_gl where fb_gl.gl = jl.gl no-lock.
  if fb_gl.autogl > 99 or fb_gl.clearact = yes then do:
    create jl_fbln.
    assign jl_fbln.flow = fb_gl.autogl
           jl_fbln.jh = jl.jh
           jl_fbln.ln = jl.ln
           jl_fbln.gl = jl.gl
           jl_fbln.crc = jl.crc
           jl_fbln.acc = jl.acc
           jl_fbln.dam = jl.dam
           jl_fbln.cam = jl.cam
           jl_fbln.whn = now
           .
  end.
end procedure.

           
    /* CIF */
f_Subled = gl.subled.
if gl.subled = "CIF" then do :
    find first aaa where aaa.aaa = kon exclusive-lock no-error.
    IF aaa.craccnt NE "" THEN 
    find first baaa where baaa.aaa = baaa.craccnt exclusive-lock no-error.
    
    find cif of aaa no-lock no-error.
    
       
    f_CIF = cif.cif.
    /*  Passive gl  */
    if gl.type = "L" then do :
        find aaa where aaa.aaa = kon exclusive-lock.
        
        find lgr of aaa no-lock no-error.
        /* Not DDA account  or DDA account without overdraft account */
        if lgr.led ne "DDA" or aaa.craccnt = "" then do :
            if opr_type = "C" then do :
                                                               
                /* Change balance  */
                if fltkey then aaa.fbal[1] = aaa.fbal[1] + kre.
                else aaa.cbal = aaa.cbal + kre.
                
                aaa.cr[1] = aaa.cr[1] + kre.
                aaa.auxdat = dat.
                sost = 1.
                
                
            end.
            if opr_type = "D" then do :
                ost = aaa.cbal - jl_debet + aaa.fbal[1].
                if (aaa.cbal - aaa.hbal) >= jl_debet then do :
                                        
                    /* Change balance   */
                    aaa.cbal = aaa.cbal - jl_debet.
                    aaa.dr[1] = aaa.dr[1] + jl_debet.
                    aaa.auxdat = dat.
                    sost = 1.
                    
                                            
                end.
                else do :
                    sost = 0.
                    mes = msnbal.
                    delete jl.
                    return.
                end.
            end.
        end.
        /* DDA account  with overdraft */
        else do :
            
            def var ovd_par as deci.
            def var ovd_cre as deci.
            
            def var toovd as deci.
            
            
            if opr_type = "C" then do :
                find aaa where aaa.aaa = kon exclusive-lock.
                krkon = aaa.craccnt.
                ost = aaa.cbal + kre + aaa.fbal[1].
                find baaa where baaa.aaa = krkon exclusive-lock. 
                                                                
                ovd_par = (baaa.opnamt - baaa.cbal).
                                
                /* O/D is full */                
                if ovd_par <= 0 then do :
                                       
                    if fltkey then 
                        aaa.fbal[1] = aaa.fbal[1] + kre.
                    else 
                        aaa.cbal = aaa.cbal + kre.
                    
                    aaa.cr[1] = aaa.cr[1] + kre.
                    aaa.auxdat = dat.
                    
                    
                end.
                else do:
                    
                    toovd =  min ( kre , ovd_par ).            
                                
                                           
                        
                    rm1 = "[[O/D RETURN FROM]] " + kon + " [[TO]] " + krkon.
                    rm2 = "".
                    rm3 = "".                                     
                    /* --- то что забираем с 7ки  ---*/
                    run aah_mak.r(output ah_numb).
                    run mk_aaldc.r (ah_numb, toovd , - toovd ,
                    kon,9,numb,21,val,rm1,rm2,rm3,1,0,dat,ofc,numb).
                    x_ah2 = ah_numb.
                    
                    /*  -> debet line  toovd with main acc TODO 21 trx*/
                    run od_jl(x_ah2).
                    
                    /* --- гасим овердрафт --- */
                    rm1 = "[[O/D DZЁ╧ANA NO]] " + kon + " [[UZ]] " + krkon.
                    rm2 = "".
                    rm3 = "".
                    run aah_mak.r(output ah_numb).
                       
                    run mk_aaldc.r (ah_numb, toovd , max( ovd_par - kre, 0.0 ) ,
                    krkon,9,numb,71,val,
                    rm1,rm2,rm3,0,0,dat,ofc,numb).
                    x_ah3 = ah_numb.
                    
                    /*  -> credit line  toovd with o/d acc TODO 71 trx*/
                    run od_jl(x_ah3).
                    
                    /* -- change krkon balance  -- */
                    baaa.auxdat = dat.
                    baaa.cr[1] = baaa.cr[1] +  toovd .
                    baaa.cbal =  baaa.cbal  +  toovd.
                                                               
                    /* -- change kon balance --*/
                    aaa.cr[1] = aaa.cr[1] + kre.
                    aaa.dr[1] = aaa.dr[1] + toovd .
                    
                    aaa.auxdat = dat.
                    if fltkey then do :
                        aaa.fbal[1] = aaa.fbal[1] + kre.
                        aaa.cbal = aaa.cbal - toovd.
                    end.    
                    else do:
                        if kre >= ovd_par then do:
                            aaa.cbal = aaa.cbal + ( kre - ovd_par) .
                        end.
                    end.
                end.
                                                
                sost = 1.
            end.
            if jl_oprtype = "D" then do :
                find aaa where aaa.aaa = kon exclusive-lock.
                krkon = aaa.craccnt.
                os_t = aaa.cbal - aaa.hbal.
                find baaa where baaa.aaa = krkon exclusive-lock.
                os_t = os_t + baaa.cbal - baaa.hbal.
                if os_t ge jl_debet or nchkaaccbalanceal then do :
                    if (aaa.cr[1] - aaa.dr[1]) ge jl_debet then do :
                                                                       
                          
                          sost = 1.
                          
                          /* Change balance  */
                          aaa.cbal = aaa.cbal - jl_debet.
                          aaa.dr[1] = aaa.dr[1] + jl_debet.
                          aaa.auxdat = dat.
                          sost = 1.
                    end.
                    else do :
                        run aah_mak.r(output ah_numb).
                        opcd = 21.
                        if opcod ne 0 then opcd = opcod.
                        run mk_aaldc.r (ah_numb,jl_debet,0.0,kon,9,
                        numb,opcd,val,rem1,rem2,rem3,1,1,dat,ofc,0).
                        x_ah1 = ah_numb.
                        
                        assign
                            
                            jl.cif = aaa.cif.
                                                    
                        sost = 1.
                        
                        rm1 = "[[O/D USE FROM]] " + krkon + " [[TO]] " + kon.
                        rm2 = "".
                        rm3 = "".
                        run aah_mak.r(output ah_numb).
                        run mk_aaldc.r (ah_numb,deb - aaa.cr[1] + aaa.dr[1],
                        baaa.cbal - baaa.opnamt - deb + aaa.cr[1] - aaa.dr[1],
                        krkon,9,numb,22,val,rm1,rm2,rm3,1,0,dat,ofc,numb).
                        x_ah2 = ah_numb.
                        
                        run od_jl(x_ah2).
                        
                        
                        run aah_mak.r(output ah_numb).
                        run mk_aaldc.r (ah_numb,deb - aaa.cr[1] + aaa.dr[1],
                        deb,kon,9,numb,71,val,rm1,rm2,rm3,0,0,dat,ofc,numb).
                        x_ah3 = ah_numb.
                        
                        run od_jl(x_ah3).
                        
                        /* Change balance  O/D */
                        baaa.cbal = baaa.cbal - deb + aaa.cr[1] - aaa.dr[1].
                        baaa.dr[1] = baaa.dr[1] + deb - aaa.cr[1] + aaa.dr[1] .
                        baaa.auxdat = dat.
                        
                        
                        /* Change balance */
                        aaa.cbal = aaa.cbal + aaa.dr[1] - aaa.cr[1].
                        aaa.cr[1] = aaa.dr[1] + deb.
                        aaa.dr[1] = aaa.dr[1] + deb .
                        aaa.auxdat = dat.
                        sost = 1.
                        
                    end.
                end.
                else do :
                   sost = 0.
                   mes = msnbal.
                   delete jl.
                   return.
                end.
            end.
        end.
    end.
end.
/* DFB */
else if gl.subled = "DFB" then do :
    if (not g-fname begins "DAYCLS") and gl.clearact = yes then do:
      find dfb where dfb.dfb = kon no-lock.
    end.
    else do:
      find dfb where dfb.dfb = kon exclusive-lock.
    end.
    
    if opr_type = "D" then do :
        if (g-fname begins "DAYCLS") or gl.clearact <> yes then do:
          dfb.dam[1] = dfb.dam[1] + deb.
          dfb.ddt[2] = dat.
        end.
        sost = 1.
    end.
    if opr_type = "C" then do :
        tem =  dfb.dam[1] + dfb.crline - dfb.cam[1].
        
        !!! calc_future_balance !!!
        for each jl_fbln where jl_fbln.acc = dfb.dfb no-lock:
          tem = tem + jl_fbln.dam - jl_fbln.cam.
        end.
        
        if tem >= kre then do :
            if (g-fname begins "DAYCLS") or gl.clearact <> yes then do:
              dfb.cam[1] = dfb.cam[1] + kre.
              
              !!! change_info
              dfb.ddt[2] = dat.
            end.
            sost = 1.
        end.
        else do :
            sost = 0.
            mes = msnbal.
            delete jl.
            return.
        end.
    end.
end.
/* ARP */
else if gl.subled = "ARP" then do :
    if gl.type = "A" then do :
        find arp where arp.arp = kon exclusive-lock.
        f_CIF = arp.cif.
        
        if opr_type = "D" then do :
          sost = 1.
                                                
                                                        
           arp.dam[1] = arp.dam[1] + deb.
           arp.ddt[2] = dat.
           
           arp.spdt = dat.
           sost = 1.
        end.
        else if opr_type = "C" then do :
           tem = arp.dam[1] - arp.cam[1] - arp.hold.
           mysum = tem.         
           if tem ge kre or nchkarpbal then do :
             arp.cam[1] = arp.cam[1] + kre.
             arp.ddt[2] = dat.
             arp.spdt = dat.
             sost = 1.
           end.
           else do :
               sost = 0.
               mes = msnbal.
               delete jl.
               return.
           end.
        end.
    end.
    if gl.type = "L" or gl.type = "O" then do :
        find arp where arp.arp = kon exclusive-lock.
               
        if opr_type = "C" then do :
           arp.cam[1] = arp.cam[1] + kre.
           arp.ddt[2] = dat.
           arp.spdt = dat.
           sost = 1.
        end.
        if opr_type = "D" then do :
           tem =  arp.cam[1] - arp.dam[1] - arp.hold.
           if tem ge deb or nchkarpbal then do :
               arp.dam[1] = arp.dam[1] + deb.
               arp.ddt[2] = dat.
               arp.spdt = dat.
               sost = 1.
           end.
           else do :
               sost = 0.
               mes = msnbal.
               delete jl.
               return.
           end.
        end.
    end.
end.
/* FUN */
else if gl.subled = "FUN" then do :
    if gl.type = "A" then do :
        find fun where fun.fun = kon exclusive-lock.
        
        if opr_type = "D" then do :
           fun.dam[1] = fun.dam[1] + deb.
           fun.ddt[2] = dat.
           sost = 1.
        end.
        if opr_type = "C" then do :
            tem =  fun.dam[1] - fun.cam[1] - fun.ydam[3].
            if tem >= kre then do :
                fun.cam[1] = fun.cam[1] + kre.
                fun.ddt[2] = dat.
                sost = 1.
            end.
            else do :
                sost = 0.
                 mes = msnbal.
                 delete jl.
                 return.
            end.
        end.
    end.
    if gl.type = "L" then do :
        find fun where fun.fun = kon exclusive-lock.
        
        if opr_type = "C" then do :
           fun.cam[1] = fun.cam[1] + kre.
           fun.ddt[2] = dat.
           sost = 1.
        end.
        if opr_type = "D" then do :
           tem =  fun.cam[1] - fun.dam[1] - fun.ydam[3].
           if tem >= deb then do :
               fun.dam[1] = fun.dam[1] + deb.
               fun.ddt[2] = dat.
               sost = 1.
           end.
           else do :
               sost = 0.
                mes = msnbal.
                delete jl.
                return.
           end.
        end.
    end.
end.
/* EPS */
else if gl.subled = "EPS" then do :
    find eps where eps.eps = kon exclusive-lock.
    
    if opr_type = "D" then do :
        eps.dam[1] = eps.dam[1] + deb.
        eps.ddt[2] = dat.
        sost = 1.
    end.
    if opr_type = "C" then do :
        tem =  eps.dam[1] - eps.cam[1].
        if tem >= kre then do :
            eps.cam[1] = eps.cam[1] + kre.
            eps.ddt[2] = dat.
            sost = 1.
        end.
        else do :
            sost = 0.
            mes = msnbal.
            delete jl.
            return.
        end.
    end.
end.
/* AST */
else if gl.subled = "AST" then do :
    find ast where ast.ast = kon exclusive-lock.
    
    if opr_type = "D" then do :
        ast.dam[1] = ast.dam[1] + deb.
        ast.ddt[2] = dat.
        sost = 1.
    end.
    if opr_type = "C" then do :
        tem =  ast.dam[1] - ast.cam[1].
        if tem >= kre then do :
            ast.cam[1] = ast.cam[1] + kre.
            ast.ddt[2] = dat.
            sost = 1.
        end.
        else do :
            sost = 0.
            mes = msnbal.
            delete jl.
            return.
        end.
    end.
end.
/* DEFAULT */
else if gl.subled = " " then  do :
    sost = 1.
end.
  find first jl where jl.jh = numb and jl.ln = lin no-error.
  if available jl then do:
    jl.cif    = f_Cif.
    run create_future_balance.
  end.
  
end.