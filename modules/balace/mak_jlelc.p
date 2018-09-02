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
DEFINE INPUT PARAMETER jl_cif AS CHARACTER.
DEFINE INPUT PARAMETER nocheckbalance AS LOG. 
define input parameter change_balance_sign as int64.
define input parameter jl_status as int64.
define input parameter jl_authorize as char.
define output parameter sost as int64.
define output parameter mes as character format "x(75)".

create jl.
    assign jl.jh     = trx_numb 
           jl.gl     = jl_glkon 
           jl.acc    = jl_account 
           jl.ln     = jl_line
           jl.dam    = jl_debet 
           jl.cam    = jl_credit 
           jl.ofc    = jl_ofc
           jl.who    = g-ofc 
           jl.whn    = today 
           jl.tim    = time
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

def var checkSD as log init yes. /* by ingsaf */
def var checkSK as log init yes. 
def var t_Rem_Template as char no-undo.

{global.i}

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
 
 FUNCTION jl_line_check INT64(trx_numb AS INT64, jl_line AS INT64):
    find first jl where jl.jh = trx_numb and jl.ln = jl_line use-index jhln no-lock no-error.
    if available jl then do :
        find last jl where jl.jh = numb use-index jhln no-lock no-error.
        if available jl then jl_line = jl.ln + 1.
    end.  
    RETURN jl_line.
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
    /* TODO Нужен процесс автоматического создания cls, glday, когда наступает новая дата - возможно, task manager*/
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
    IF isValidTrxNumber(trx_numb) = NO THEN UNDO, RETURN.
    FIND FIRST jh WHERE jh.jh = trx_numb EXCLUSIVE-LOCK NO-ERROR.
    
    jl_line = jl_line_check(trx_numb,jl_line).
    
    IF isValidGlAccount(jl_glkon) = NO THEN UNDO, RETURN.
    find gl where gl.gl = jl_glkon NO-LOCK NO-ERROR.
    
    IF isValidCurrency(jl_currency) = NO THEN UNDO, RETURN.
    find crc where crc.crc = jl_currency no-lock no-error.
    if available crc then do :
        jl_debet = round(jl_debet,crc.decpnt).
        jl_credit = round(jl_credit,crc.decpnt).
    end.
        
    IF isValidGlAccount(jl_dat) = NO THEN UNDO, RETURN.
    
    IF gl.subled NE "" THEN DO:
        run ValidateSubacc(jl_account, jl_currency, jl_oprtype, OUTPUT odaccount, OUTPUT isOK, OUTPUT mes). 
        IF isok = NO THEN UNDO, RETURN.
        FIND FIRST subacc WHERE subacc.account = jl_account AND subacc.crc = jl_currency EXCLUSIVE-LOCK NO-ERROR.
        jl_cif = subacc.cif.
        RUN calc_balance(subacc.account,subacc.odaccount, subacc.gl, subacc.crc, jl_dat, gl.type, OUTPUT isok, OUTPUT mes, 
        OUTPUT account_balance).
        IF isok = NO THEN UNDO, RETURN.
        IF nocheckbalance = NO THEN DO:
            RUN chk_balance(account_balance, gl.type, jl_oprtype, jl_debet, jl_credit, OUTPUT isok, OUTPUT mes).
        END.
        ELSE isok = YES.
        IF isok = NO THEN UNDO, RETURN.   
        RUN make_jl_line().
        
        /* Пока не ясно, надо ли это делать 
        RUN if_need_od_line(OUTPUT need_od_line).
    
        IF need_od_line = YES THEN DO:
            make_od_line().
        END.
        */
        /* Это признак того, что надо накатывать остаток сразу */
        IF change_balance_sign = YES THEN RUN DO:
            RUN change_gl_balance(jl_glkon, jl_dat, gl.subled, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok). 
            IF isok = NO THEN UNDO, RETURN.
            RUN change_account_balance(jl_account, jl_dat, gl.subled, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
            RUN change_info_account(jl_account, jl_dat, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
        END.
        ELSE DO:
            RUN create_future_account_balance(trx_numb, jl_line, jl_glkon,jl_account, jl_dat, gl.subled, jl_oprtype,
            jl_currency, jl_currency,jl_debet, jl_credit, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
        END.  
        isok = YES.
    END.
    ELSE DO:
        isok = YES.
        IF change_balance_sign = YES THEN RUN change_gl_balance(jl_glkon, jl_dat, gl.subled, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
        ELSE RUN reate_future_account_balance(trx_numb, jl_line, jl_glkon,jl_account, jl_dat, gl.subled, jl_oprtype,
        jl_currency, jl_currency,jl_debet, jl_credit, OUTPUT isok).
        IF isok = NO THEN UNDO, RETURN.
    END.
    
    /* Надо подумать, делать ли овердрафтные линии 
    по каждой транзакции или одну результирующую линию в конце дня 
    
    Также надо подумать об автоматическом накате остатков по субсчетам - делать это отдельным
    процессом, а не в самой транзакции */
end.

procedure ValidateSubacc : 
    DEFINE INPUT PARAMETER jl_account AS CHARACTER. 
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE OUTPUT PARAMETER odaccount AS CHARACTER.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    DEFINE OUTPUT PARAMETER Errmes AS CHARACTER.
    
    DEFINE BUFFER bf_subacc FOR subacc.
    
    OK = NO.
    find first subacc where subacc.account = jl_account AND subacc.crc = jl_currency exclusive-lock no-error.
    if avail subacc and jl_oprtype = "D" then do:
        find first aas where aas.account = subacc.account AND aas.sic = "SD" no-lock no-error. 
        if avail aas and checkSD then do:
            Errmes = " Stop Debet instruction for " + jl_account +  " " + aas.reason.
            return .
        end.
    end.    
    else if avail subacc and jl_oprtype = "C" then do:
        find first aas where aas.account = subacc.account AND aas.sic = "SK" no-lock no-error. 
        if avail aas and checkSK then do:
            Errmes = " Stop Credit instruction for " + jl_account +  " " + aas.reason.
            return .
        end.
    end.
    if subacc.gl ne glkon then do :
        Errmes = "Balance account in TRX differs from balance account in SubAccount " + jl_account + " !".
        return.
    end.
    if subacc.crc ne val then do :
        Errmes = "Currency in TRX differs from currency in SubAccount " + jl_account + " !".
        return.
    end. 
    IF subacc.sts = "C" THEN DO:
        Errmes = "SubAccount " + jl_account + " is closed!".
        RETURN.
    END.
    IF subacc.odaccount NE "" THEN DO:
        odaccount = subacc.odaccount.
        find first bf_subacc where bf_subacc.account = odaccount AND bf_subacc.crc = jl_currency exclusive-lock no-error.
    end.    
        
    OK = YES.
    
END PROCEDURE. 

PROCEDURE calc_balance :
    DEFINE INPUT PARAMETER account AS CHARACTER.
    DEFINE INPUT PARAMETER odaccount AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl AS INT64.
    DEFINE INPUT PARAMETER account_crc AS INT64.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
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
    accbalance.cbalancedate EQ opr_date AND accbalance.crc = account_crc EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE accbalance THEN DO:
        RUN create_accbalance(account,account_gl, account_crc, opr_date,OUTPUT okbal).
        IF okbal = <> "" THEN DO:
            ErrMes = "Can't calculate Account Balance!".
            UNDO, RETURN.
        END.    
        FIND FIRST accbalance WHERE accbalance.account = account AND 
        accbalance.cbalancedate EQ opr_date AND accbalance.crc = account_crc EXCLUSIVE-LOCK NO-ERROR.
    END.
    account_balance = accbalance.cbalance - accbalance.hold.
    RUN calc_future_balance(account, account_crc, opr_date, gl_type, OUTPUT acc_future_balance).
    account_balance = account_balance + acc_future_balance.
    IF odaccount NE "" THEN DO:
        FIND FIRST bf_subacc WHERE bf_subacc.account = odaccount EXCLUSIVE-LOCK NO-ERROR.
        FIND FIRST bf_accbalance WHERE bf_accbalance.account = odaccount AND 
        bf_accbalance.cbalancedate EQ opr_date AND bf_accbalance.crc = account_crc EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE bf_accbalance THEN DO:
            RUN create_accbalance(odaccount, bf_subacc.gl, bf_subacc.crc, opr_date,OUTPUT okbal).
            IF okbal = NO THEN DO:
                ErrMes = "Can't calculate O/D Account Balance!".
                UND0, RETURN.
            END.    
            FIND FIRST bf_accbalance WHERE bf_accbalance.account = odaccount AND 
            bf_accbalance.cbalancedate EQ opr_date AND bf_accbalance.crc = account_crc EXCLUSIVE-LOCK NO-ERROR.
        END.
        account_balance = account_balance + (bf_accbalance.cbalance - bf_accbalance.hold).
    END.
    OK = YES.
END PROCEDURE.


PROCEDURE create_accbalance :
    DEFINE INPUT PARAMETER account     AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl  AS INT64.
    DEFINE INPUT PARAMETER account_crc AS int64.
    DEFINE INPUT PARAMETER opr_date    AS DATE.
    DEFINE OUTPUT PARAMETER ok         AS CHAR.
    DEFINE BUFFER bf_accbalance FOR accbalance.
    
    ok = "NO-ACCBALANCE".
    FIND last bf_accbalance WHERE bf_accbalance.account = account AND accbalance.crc = account_crc AND
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
    ok = "".
END PROCEDURE.

PROCEDURE check_balance :
    DEFINE INPUT PARAMETER account_balance AS DECIMAL.
    DEFINE INPUT PARAMETER gltype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER debet AS DECIMAL.
    DEFINE INPUT PARAMETER credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    DEFINE OUTPUT PARAMETER Errmes AS CHARACTER.
    
    OK = NO.
    
    IF ((gl_type = "A" OR gl_type = "E") AND jl_oprtype = "D") OR 
       ((gl_type = "L" OR gl_type = "O" OR gl_type = "R") AND jl_oprtype = "C") THEN DO:
        OK = YES.
        RETURN.
    END.
    IF ((gl_type = "A" OR gl_type = "E") AND jl_oprtype = "C" AND account_balance GE credit) OR
       ((gl_type = "L" OR gl_type = "O" OR gl_type = "R") AND jl_oprtype = "D" AND account_balance GE debet) THEN DO:
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
           jl.ofc    = jl_ofc
           jl.who    = g-ofc 
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

PROCEDURE change_gl_balance:
    DEFINE INPUT PARAMETER jl_glkon AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
    FOR EACH glbalance WHERE glbalance.account = account AND 
        glbalance.balancedate ge opr_date AND glbalance.crc = jl_currency EXCLUSIVE-LOCK :
        assign
            glbalance.total_debet = glbalance.total_debet + jl_debet
            glbalance.total_credit = glbalance.total_credit + jl_credit.
        
        IF jl_oprtype = "D" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN glbalance.balance = glbalance.balance + jl_debet.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") then glbalance.balance = glbalance.balance - jl_debet.
        END. 
        ELSE IF jl_oprtype = "C" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN glbalance.balance = glbalance.balance - jl_credit.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") THEN glbalance.balance = glbalance.balance + jl_credit.
        END.        
    END.    
    OK = YES.
    
END PROCEDURE.    

PROCEDURE change_account_balance:
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
    FOR EACH accbalance WHERE accbalance.account = account AND 
        accbalance.cbalancedate ge opr_date AND accbalance.crc = jl_currency EXCLUSIVE-LOCK :
        assign
            accbalance.total_debet = accbalance.total_debet + jl_debet
            accbalance.total_credit = accbalance.total_credit + jl_credit.
        
        IF jl_oprtype = "D" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN accbalance.cbalance = accbalance.cbalance + jl_debet.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") then accbalance.cbalance = accbalance.cbalance - jl_debet.
        END. 
        ELSE IF jl_oprtype = "C" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN accbalance.cbalance = accbalance.cbalance - jl_credit.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R" ) THEN accbalance.cbalance = accbalance.cbalance + jl_credit.
        END.        
        accbalance.availbal = accbalance.cbalance - accbalance.holdbal.
    END.    
    OK = YES.
END PROCEDURE.

PROCEDURE create_future_account_balance:
    DEFINE INPUT PARAMETER trx_numb AS INT64.
    DEFINE INPUT PARAMETER jl_line AS INT64.
    DEFINE INPUT PARAMETER jl_glkon AS INT64.
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    create accbalance_future.
    assign accbalance_future.flow = "account_balance"
           accbalance_future.jh = trx_numb
           accbalance_future.line = jl_line
           accbalance_future.gl = jl_glkon
           accbalance_future.crc = jl_currency
           accbalance_future.account = jl_account
           accbalance_future.jldat = opr_date
           accbalance_future.dam = jl_debet
           accbalance_future.cam = jl_credit
           accbalance_future.dc = jl_oprtype
           accbalance_future.gltype  = gl_type
           accbalance_future.whn = NOW.
    OK = YES.       
end procedure.

PROCEDURE calc_future_balance:
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE OUTPUT PARAMETER acc_future_balance AS DECIMAL.
    
    FOR EACH accbalance_future WHERE acncbalance_future.flow = "account_balance" AND accbalance_future.account = jl_account AND
        accbalance_future.crc = jl_currency AND accbalance_future.jldat LE opr_date no-lock:
        IF gl_type = "A" OR gl_type = "E" THEN acc_future_balance = acc_future_balance + accbalance_future.dam - accbalance_future.cam.
        ELSE gl_type = "L" OR gl_type = "O" OR gl_type = "R" THEN 
        acc_future_balance = acc_future_balance + accbalance_future.cam - accbalance_future.dam.
    END.
END PROCEDURE.    
    

PROCEDURE change_info_account:

    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS INT64.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    OK = NO.
    
    find first subacc where subacc.account = jl_account AND subacc.crc = jl_currency exclusive-lock no-error.
    if AVAILABLE subacc THEN DO:
        IF jl_oprtype = "D" AND subacc.lastdebetdate < opr_date THEN DO:
            subacc.lastdebetdate = opr_date.
            subacc.lastdebet = jl_debet.
        END.  
        ELSE IF jl_oprtype = "C" AND subacc.lastcreditdate < opr_date THEN DO:
            subacc.lastcreditdate = opr_date.
            subacc.lastcredit = jl_credit.
        END. 
        IF subacc.lastoperationdate < opr_date THEN subacc.lastoperationdate = opr_date.
        OK = YES.
    END.
END PROCEDURE.
