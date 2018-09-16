/* Main procedure for creating jl */

define input parameter jl_header    AS int64.
define input parameter jl_glkon    AS int.
define input parameter jl_account  AS character.
define input parameter jl_line     AS int64.
define input parameter jl_debet    AS dec.
define input parameter jl_credit   AS dec.
define input parameter jl_details  AS char.
define input parameter jl_oprtype    AS char.
define input parameter jl_currency AS char.
define input parameter jl_dat      AS date.
define input parameter jl_ofc      AS char.
define input parameter jl_cif as character.
define input parameter nocheckbalance AS LOG. 
define input parameter change_balance_sign as log.
define input parameter jl_status as int.
define input parameter jl_authorize_user as char.
define input parameter jl_authorize_date AS DATE.
define output parameter sost as int64.
define output parameter mes as character format "x(75)".

def var checkSD as log init yes. 
def var checkSK as log init yes. 
def var t_Rem_Template as char no-undo.
DEFINE VARIABLE overdraft_account AS CHARACTER.
DEFINE VARIABLE isok AS LOG.
DEFINE VARIABLE account_balance AS DECIMAL.

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
FUNCTION isValidCurrency LOG(currency AS char):
    DEFINE BUFFER bf_currency FOR currency.
    find bf_currency where bf_currency.currency = currency no-lock no-error.
    if not available bf_currency then do:
        setError(0, "Currency " + string(currency) +  " is incorrect!").
        return false.
    end. 
    return true.
END.
FUNCTION isValidGlAccount LOG(iGl AS INT):
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
 
 FUNCTION  isGlBalance LOG (jl_glkon AS INTEGER, jl_currency AS char, jl_dat AS DATE):
    find first gl_balance WHERE gl_balance.gl = jl_glkon AND 
    gl_balance.balance_date eq jl_dat AND gl_balance.currency = jl_currency NO-LOCK NO-ERROR.
    RETURN AVAILABLE gl_balance.
 END. 
 
 FUNCTION isValidTrxNumber LOG(jl_header AS INT64):
    find FIRST transaction_header WHERE transaction_header.header_id = jl_header no-lock no-error.
    if not available transaction_header then do:
        setError(0, "Incorrect Transaction Number " + string(jl_header) +  " !").
        return false.
    end.
    return true.
 END.
 
 FUNCTION jl_line_check INT64(jl_header AS INT64, jl_line AS INT64):
    find first transaction_line where transaction_line.header_id = jl_header and transaction_line.line = jl_line use-index header_id no-lock no-error.
    if available transaction_line then do :
        find last transaction_line where transaction_line.header_id = jl_header use-index header_id no-lock no-error.
        if available transaction_line then jl_line = transaction_line.line + 1.
    end.  
    RETURN jl_line.
 END.
 
 FUNCTION isValidTrxDate LOG(trx_dat AS date):
    find FIRST closed_days WHERE closed_days.balance_date = trx_dat no-lock no-error.
    if not available closed_days then do:
        IF trx_dat = TODAY THEN DO:
            RUN open_new_balance_date(trx_dat). /* TODO !!!!! closed_days create, glday create */
            RETURN TRUE.
        END.
        setError(0, "Incorrect Transaction Date " + string(trx_dat) +  " !").
        return false.
    end.
    ELSE IF closed_days.closed = YES THEN DO:
        setError(0, "Date is closed for operations " + string(trx_dat) +  " !").
        return false.
    END.
    return true.
    /* TODO Нужен процесс автоматического создания closed_days, glday, когда наступает новая дата - возможно, task manager*/
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
    IF isValidTrxNumber(jl_header) = NO THEN UNDO, RETURN.
    FIND FIRST transaction_header WHERE transaction_header.header_id = jl_header EXCLUSIVE-LOCK NO-ERROR.

    jl_line = jl_line_check(jl_header,jl_line).
    
    IF isValidGlAccount(jl_glkon) = NO THEN UNDO, RETURN.
    find gl where gl.gl = jl_glkon NO-LOCK NO-ERROR.
    DISPLAY "2 stage".
    PAUSE.
    
    IF isGlBalance(jl_glkon, jl_currency, jl_dat) = NO THEN change_balance_sign = NO.
    
    IF isValidCurrency(jl_currency) = NO THEN UNDO, RETURN.
    find FIRST currency where currency.currency = jl_currency no-lock no-error.
    if available currency then do :
        jl_debet = round(jl_debet,currency.decimal_points).
        
        jl_credit = round(jl_credit,currency.decimal_points).
    end.
        
    IF isValidtrxdate(jl_dat) = NO THEN UNDO, RETURN.
    
    IF gl.subledger_type NE "" THEN DO:
        run Validateaccount(jl_account, jl_currency, jl_oprtype, OUTPUT overdraft_account, OUTPUT isOK, OUTPUT mes). 
        IF isok = NO THEN UNDO, RETURN.
        FIND FIRST account WHERE account.account = jl_account AND account.currency = jl_currency EXCLUSIVE-LOCK NO-ERROR.
        jl_cif = account.cif.
        RUN calc_balance(account.account,account.overdraft_account, account.gl, account.currency, jl_dat, gl.gl_type, OUTPUT isok, OUTPUT mes, 
        OUTPUT account_balance).
        IF isok = NO THEN UNDO, RETURN.
        IF nocheckbalance = NO THEN DO:
            RUN check_balance(account.account, account_balance, gl.gl_type, jl_oprtype, jl_debet, jl_credit, OUTPUT isok, OUTPUT mes).
        END.
        ELSE isok = YES.
        IF isok = NO THEN UNDO, RETURN.   
        RUN make_transaction_line.
        
        /* Пока не ясно, надо ли это делать 
        RUN if_need_od_line(OUTPUT need_od_line).
    
        IF need_od_line = YES THEN DO:
            make_od_line().
        END.
        */
        /* Это признак того, что надо накатывать остаток сразу */
        IF change_balance_sign = YES THEN DO:
            RUN change_gl_balance(jl_glkon, jl_dat, gl.gl_type, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok). 
            IF isok = NO THEN UNDO, RETURN.
            
            RUN change_account_balance(jl_account, jl_dat, gl.gl_type, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
            RUN change_info_account(jl_account, jl_dat, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
        END.
        ELSE DO:
            RUN create_future_account_balance(jl_header, jl_line, jl_glkon,jl_account, jl_dat, gl.gl_type, jl_oprtype,
            jl_currency, jl_debet, jl_credit, jl_ofc, OUTPUT isok).
            IF isok = NO THEN UNDO, RETURN.
        END.  
        isok = YES.
    END.
    ELSE DO:
        isok = YES.
        IF change_balance_sign = YES THEN RUN change_gl_balance(jl_glkon, jl_dat, gl.gl_type, jl_oprtype, jl_currency, jl_debet, jl_credit, OUTPUT isok).
        ELSE RUN create_future_account_balance(jl_header, jl_line, jl_glkon, jl_account, jl_dat, gl.gl_type, jl_oprtype,
        jl_currency, jl_debet, jl_credit, jl_ofc, OUTPUT isok).
        IF isok = NO THEN UNDO, RETURN.
    END.
    sost = 1.
    RETURN.
    
    /* Надо подумать, делать ли овердрафтные линии 
    по каждой транзакции или одну результирующую линию в конце дня 
    
    Также надо подумать об автоматическом накате остатков по субсчетам - делать это отдельным
    процессом, а не в самой транзакции */
end.

procedure Validateaccount : 
    DEFINE INPUT PARAMETER jl_account AS CHARACTER. 
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE OUTPUT PARAMETER overdraft_account AS CHARACTER.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    DEFINE OUTPUT PARAMETER Errmes AS CHARACTER.
    
    DEFINE BUFFER bf_account FOR account.
    
    OK = NO.
    find first account where account.account = jl_account AND account.currency = jl_currency exclusive-lock no-error.
    if avail account and jl_oprtype = "D" then do:
        find first aas where aas.aaa = account.account AND aas.sic = "SD" no-lock no-error. 
        if avail aas and checkSD then do:
            Errmes = " Stop Debet instruction for " + jl_account +  " " + aas.payee.
            return .
        end.
    end.    
    else if avail account and jl_oprtype = "C" then do:
        find first aas where aas.aaa = account.account AND aas.sic = "SK" no-lock no-error. 
        if avail aas and checkSK then do:
            Errmes = " Stop Credit instruction for " + jl_account +  " " + aas.payee.
            return .
        end.
    end.
    if account.gl ne jl_glkon then do :
        Errmes = "Balance account in TRX differs from balance account in account " + jl_account + " !".
        return.
    end.
    if account.currency ne jl_currency then do :
        Errmes = "Currency in TRX differs from currency in account " + jl_account + " !".
        return.
    end. 
    IF account.account_status = "CLOSE" THEN DO:
        Errmes = "Account " + jl_account + " is closed!".
        RETURN.
    END.
    IF account.overdraft_account NE "" THEN DO:
        overdraft_account = account.overdraft_account.
        find first bf_account where bf_account.account = overdraft_account AND bf_account.currency = jl_currency exclusive-lock no-error.
    end.    
        
    OK = YES.
    
END PROCEDURE. 

PROCEDURE calc_balance :
    DEFINE INPUT PARAMETER account AS CHARACTER.
    DEFINE INPUT PARAMETER overdraft_account AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl AS INT64.
    DEFINE INPUT PARAMETER account_currency AS char.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE OUTPUT PARAMETER ok AS LOG.
    DEFINE OUTPUT PARAMETER ErrMes AS CHARACTER.
    DEFINE OUTPUT PARAMETER account_balance AS dec.
    
    DEFINE BUFFER bf_account_balance FOR account_balance.
    DEFINE BUFFER bf_account FOR account.
    
    DEFINE VARIABLE acc_future_balance AS DECIMAL.
    DEFINE VARIABLE odacc_future_balance AS DECIMAL.
    DEFINE VARIABLE okbal AS char.
    
    OK = NO.
    FIND FIRST account_balance WHERE account_balance.account = account AND 
    account_balance.balance_date EQ opr_date AND account_balance.currency = account_currency EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE account_balance THEN DO:
        RUN create_account_balance(account,account_gl, account_currency, opr_date,OUTPUT okbal).
        IF okbal <> "" THEN DO:
            ErrMes = "Can't calculate Account Balance!".
            UNDO, RETURN.
        END.    
        FIND FIRST account_balance WHERE account_balance.account = account AND 
        account_balance.balance_date EQ opr_date AND account_balance.currency = account_currency EXCLUSIVE-LOCK NO-ERROR.
    END.
    account_balance = account_balance.balance - account_balance.hold_balance.
    RUN calc_future_balance(account, account_currency, opr_date, gl_type, OUTPUT acc_future_balance).
    account_balance = account_balance + acc_future_balance.
    IF overdraft_account NE "" THEN DO:
        FIND FIRST bf_account WHERE bf_account.account = overdraft_account EXCLUSIVE-LOCK NO-ERROR.
        FIND FIRST bf_account_balance WHERE bf_account_balance.account = overdraft_account AND 
        bf_account_balance.balance_date EQ opr_date AND bf_account_balance.currency = account_currency EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE bf_account_balance THEN DO:
            RUN create_account_balance(overdraft_account, bf_account.gl, bf_account.currency, opr_date,OUTPUT okbal).
            IF okbal <> "" THEN DO:
                ErrMes = "Can't calculate O/D Account Balance!".
                UNDO, RETURN.
            END.    
            FIND FIRST bf_account_balance WHERE bf_account_balance.account = overdraft_account AND 
            bf_account_balance.balance_date EQ opr_date AND bf_account_balance.currency = account_currency EXCLUSIVE-LOCK NO-ERROR.
        END.
        account_balance = account_balance + (bf_account_balance.balance - bf_account_balance.hold_balance).
    END.
    OK = YES.
END PROCEDURE.


PROCEDURE create_account_balance :
    DEFINE INPUT PARAMETER account     AS CHARACTER.
    DEFINE INPUT PARAMETER account_gl  AS INT64.
    DEFINE INPUT PARAMETER account_currency AS char.
    DEFINE INPUT PARAMETER opr_date    AS DATE.
    DEFINE OUTPUT PARAMETER ok         AS CHAR.
    DEFINE BUFFER bf_account_balance FOR account_balance.
        
    ok = "NO-account_balance".
    FIND last bf_account_balance WHERE bf_account_balance.account = account AND account_balance.currency = account_currency AND
    bf_account_balance.balance_date lt opr_date EXCLUSIVE-LOCK NO-ERROR. 
    IF AVAILABLE bf_account_balance THEN DO:
        CREATE account_balance.
        BUFFER-COPY bf_account_balance TO account_balance.
        account_balance.id = NEXT-VALUE(account_balance_id).
        account_balance.balance_date = opr_date.
        /* Trigger na whn */
    END.
    ELSE DO:
        create account_balance.
        assign
            account_balance.id = NEXT-VALUE(account_balance_id)
            account_balance.account = account
            account_balance.gl      = account_gl
            account_balance.balance_date = opr_date
            account_balance.currency     = account_currency.
            /* Trigger na whn */
    END.
    ok = "".
END PROCEDURE.

PROCEDURE check_balance :
    DEFINE INPUT PARAMETER account AS CHARACTER.
    DEFINE INPUT PARAMETER account_balance AS DECIMAL.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
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

PROCEDURE make_transaction_line:
    create transaction_line.
    assign transaction_line.id = NEXT-VALUE(transaction_line_id)
           transaction_line.header_id        = jl_header 
           transaction_line.gl               = jl_glkon 
           transaction_line.account          = jl_account 
           transaction_line.debet            = jl_debet 
           transaction_line.credit           = jl_credit 
           transaction_line.create_user      = jl_ofc
           transaction_line.create_date      = now
           transaction_line.modify_user      = g-ofc 
           transaction_line.modify_date      = now
           transaction_line.line             = jl_line
           transaction_line.balance_date     = jl_dat 
           transaction_line.details_template = jl_details 
           transaction_line.dc               = jl_oprtype 
           transaction_line.currency         = jl_currency
           transaction_line.line_status      = jl_status
           transaction_line.authorize_user   = jl_authorize_user
           transaction_line.authorize_date   = jl_authorize_date
           transaction_line.cif              = jl_cif. 
END PROCEDURE.

PROCEDURE change_gl_balance:
    DEFINE INPUT PARAMETER jl_glkon AS INTEGER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
    FOR EACH gl_balance WHERE gl_balance.gl = jl_glkon AND 
        gl_balance.balance_date ge opr_date AND gl_balance.currency = jl_currency EXCLUSIVE-LOCK :
        assign
            gl_balance.total_debet = gl_balance.total_debet + jl_debet
            gl_balance.total_credit = gl_balance.total_credit + jl_credit.
        
        IF jl_oprtype = "D" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN gl_balance.balance = gl_balance.balance + jl_debet.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") then gl_balance.balance = gl_balance.balance - jl_debet.
        END. 
        ELSE IF jl_oprtype = "C" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN gl_balance.balance = gl_balance.balance - jl_credit.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") THEN gl_balance.balance = gl_balance.balance + jl_credit.
        END.        
    END.    
    OK = YES.
    
END PROCEDURE.    

PROCEDURE change_account_balance:
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    /* Nakat ostatka ot dati operaciji do poslednej otkritoj dati */
    FOR EACH account_balance WHERE account_balance.account = jl_account AND 
        account_balance.balance_date ge opr_date AND account_balance.currency = jl_currency EXCLUSIVE-LOCK :
        assign
            account_balance.total_debet = account_balance.total_debet + jl_debet
            account_balance.total_credit = account_balance.total_credit + jl_credit.
        
        IF jl_oprtype = "D" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN account_balance.balance = account_balance.balance + jl_debet.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R") then account_balance.balance = account_balance.balance - jl_debet.
        END. 
        ELSE IF jl_oprtype = "C" THEN DO:
            IF (gl_type = "A" OR gl_type = "E") THEN account_balance.balance = account_balance.balance - jl_credit.
            ELSE IF (gl_type = "L" OR gl_type = "O" OR gl_type = "R" ) THEN account_balance.balance = account_balance.balance + jl_credit.
        END.        
        account_balance.available_balance = account_balance.balance - account_balance.hold_balance.
    END.    
    OK = YES.
END PROCEDURE.

PROCEDURE create_future_account_balance:
    DEFINE INPUT PARAMETER jl_header AS INT64.
    DEFINE INPUT PARAMETER jl_line AS INT64.
    DEFINE INPUT PARAMETER jl_glkon AS INT64.
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL.
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE INPUT PARAMETER jl_ofc AS CHARACTER.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    
    OK = NO.
    create account_balance_future.
    assign account_balance_future.action = "account_balance"
           account_balance_future.header_id = jl_header
           account_balance_future.line = jl_line
           account_balance_future.gl = jl_glkon
           account_balance_future.currency = jl_currency
           account_balance_future.account = jl_account
           account_balance_future.balance_date = opr_date
           account_balance_future.debet = jl_debet
           account_balance_future.credit = jl_credit
           account_balance_future.dc = jl_oprtype
           account_balance_future.gl_type  = gl_type
           account_balance_future.create_date = NOW
           account_balance_future.create_user = jl_ofc.
    OK = YES.       
end procedure.

PROCEDURE calc_future_balance:
    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER gl_type AS CHARACTER.
    DEFINE OUTPUT PARAMETER acc_future_balance AS DECIMAL.
    
    FOR EACH account_balance_future WHERE account_balance_future.action = "account_balance" AND account_balance_future.account = jl_account AND
        account_balance_future.currency = jl_currency AND account_balance_future.balance_date LE opr_date no-lock:
        IF gl_type = "A" OR gl_type = "E" THEN acc_future_balance = acc_future_balance + account_balance_future.debet - account_balance_future.credit.
        ELSE IF gl_type = "L" OR gl_type = "O" OR gl_type = "R" THEN 
        acc_future_balance = acc_future_balance + account_balance_future.credit - account_balance_future.debet.
    END.
END PROCEDURE.    
    

PROCEDURE change_info_account:

    DEFINE INPUT PARAMETER jl_account AS CHARACTER.
    DEFINE INPUT PARAMETER opr_date AS DATE.
    DEFINE INPUT PARAMETER jl_oprtype AS CHARACTER.
    DEFINE INPUT PARAMETER jl_currency AS char.
    DEFINE INPUT PARAMETER jl_debet as DECIMAL. 
    DEFINE INPUT PARAMETER jl_credit AS DECIMAL.
    DEFINE OUTPUT PARAMETER OK AS LOG.
    OK = NO.
    
    find first account where account.account = jl_account AND account.currency = jl_currency exclusive-lock no-error.
    if AVAILABLE account THEN DO:
        IF jl_oprtype = "D" AND (account.last_debet_date < opr_date OR account.last_debet_date = ?) THEN DO:
            account.last_debet_date = opr_date.
            account.last_debet_amount = jl_debet.
        END.  
        ELSE IF jl_oprtype = "C" AND (account.last_credit_date < opr_date OR account.last_credit_date = ?) THEN DO:
            account.last_credit_date = opr_date.
            account.last_credit_amount = jl_credit.
        END. 
        IF account.last_operation_date < opr_date OR account.last_operation_date = ?
        THEN account.last_operation_date = opr_date.
        OK = YES.
    END.
END PROCEDURE.
