USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.

DEFINE VARIABLE oError AS CHARACTER.
define variable j  as int64 format "9" initial 0.
define variable j1 as int64 format "9" initial 0.
define variable j2 as int64 format "9" initial 0.
define variable j3 as int64 format "9" initial 0.
define variable i1 as int64 format "9" initial 0.
define variable i2 as int64 format "9" initial 0.
define variable i3 as int64 format "9" initial 0.
define variable m  as int64 format "9" initial 0.
define variable m1 as int64 format "9" initial 0.
define variable m2 as int64 format "9" initial 0.
define variable k  as int64 format "9" initial 0.
define variable k1 as int64 format "9" initial 0.
define variable dop1 as int64 initial 0.
define variable sost as int64.
define variable sost2 as int64.
define variable t_DC like transaction_line.dc.
define variable i as int64 initial 0.
def var k2 as int64.
def var debx as dec extent 50.
def var krex as dec extent 50.
def var ubkey as log init no.
define variable ques2 as logical format "Yes/No" initial no.

/*
def var baseCrc as int64 no-undo.
def var baseCcy as cha no-undo.
run base_crc.r(output baseCrc,output baseCcy).
def var expkey as log init no.
def var sgn as int64.
{sysc.f}
{mlaaad_cls.i}
define input parameter key as int64.

define variable deb  like transaction_line.dam.
define variable kre  like transaction_line.dam.
define variable j  as int64 format "9" initial 0.
define variable j1 as int64 format "9" initial 0.
define variable j2 as int64 format "9" initial 0.
define variable j3 as int64 format "9" initial 0.
define variable i1 as int64 format "9" initial 0.
define variable i2 as int64 format "9" initial 0.
define variable i3 as int64 format "9" initial 0.
define variable m  as int64 format "9" initial 0.
define variable m1 as int64 format "9" initial 0.
define variable m2 as int64 format "9" initial 0.
define variable k  as int64 format "9" initial 0.
define variable k1 as int64 format "9" initial 0.
def new shared var s-gl like gl.gl.
def new shared var s-crc like crc.crc.
def buffer bgl for gl.
def var lonkey as log init no.
define variable oldtrval like crc.crc.
define variable line as int64 format "9999".
define variable glkon like transaction_line.gl.
define variable subl as character format "x(10)" /*case-sensitive*/ . /* by serkuz */
def var subliban as char format "x(21)" /* case-sensitive */ . /* by vadvas */
define variable kom as character format "x(65)" extent 3.
define variable val like transaction_line.crc.
define variable debet like transaction_line.dam.
define variable credit like transaction_line.cam.
define variable oldt_DC like transaction_line.dc.
define variable t_DC like transaction_line.dc.
define variable i as int64 initial 0.
define variable auxs as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable atl1 as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable totost as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable atl like aaa.cbal.
define variable ost7 as decimal format "->>>,>>>,>>>,>>>,>>9.99".
define variable mes as character format "x(78)".
define variable mes2 as character format "x(78)".
define variable mesx as character format "x(78)".
define variable krkon like aaa.aaa.
define variable overd like aaa.aaa.
define variable dop1 as int64 initial 0.
define variable short like transaction_line.aah.

define variable sost as int64.
define variable sost2 as int64.
define variable sost3 as int64 initial 0.
define variable sum_rem like transaction_line.dam initial 0.0.
define variable ques2 as logical format "Yes/No" initial no.
def var casgl like gl.gl.
def var brcash like gl.gl.
def var nsgl like gl.gl.
def var pcod as int64 format "999".
def var keyres as log init no.
def var keynores as log init no.
def var prefix as char format "!(2)".
def var cndes as char format "x(25)".
def var chbr as int64.
def var k2 as int64.
def var ubkey as log init no.
def var debx as dec extent 50.
def var krex as dec extent 50.
def var ost7x as dec.
def var strx as char.
def var mdat as date.
def var dx1 as date.
def var dx2 as date.
def var nam as char.
def var ques1 as log.
def var codkey as log.
def var card as log.
def var srvkey as log.
def var sblxx as char.
def var idepoind as int.
def var cbnk as sysbnk.
def var logstr as char.
cbnk = new sysbnk().
def buffer s_jl for bank.transaction_line.
def buffer s_gl for bank.gl.
def buffer s_crc for bank.crc.
def var saldo as decimal extent.
find last crc no-lock no-error.
extent(saldo) = crc.crc.
*/
define input parameter key as int64.

define variable deb  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable kre  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable atl  AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99-".
define variable debet AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable credit AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
define variable line as integer format "9999".
define variable glkon AS INT64 FORMAT "zzzzzzz9".
define variable t_Account as character format "x(12)" .
define variable t_Header_Id as int64 format ">>>>>>>>>9".
define variable currency AS CHARACTER FORMAT "x(3)".
define variable account_name as character.
define variable details as character format "x(65)".
define variable trx_date AS DATE. 


DEFINE VARIABLE id AS INT64.

DEFINE TEMP-TABLE totbal NO-UNDO
    FIELD currency AS CHARACTER
    FIELD debet AS DECIMAL
    FIELD credit AS DECIMAL
    INDEX currency currency ASC.

/********/
DEFINE VARIABLE trHeader  AS transactionHeaderModel.
DEFINE VARIABLE trLine    AS transactionLineModel.
/************/
/* Alex_ Z Example
DO TRANSACTION:
    REPEAT WHILE TRUE:
        IF NOT VALID-OBJECT(trHeader) THEN
            oError = transactionApi:createHeader(INPUT-OUTPUT trHeader). 
        
        trLine  = transactionApi:createLineModel(trHeader).
        
        UPDATE ln.
        
        trLine:EMPTY().
        trLine:getDb(jh, ln).
        ASSIGN  tmpGl  = trLine:gl
                tmpDC tmpAmount tmpCurrency tmpDetails
        UPDATE tmpGl tmpDC tmpAmount tmpCurrency tmpDetails.
        
        oError = trLine:setLineData(tmpGl, tmpDC, tmpAmount, tmpCurrency, tmpDetails).
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-CREDIT-DATA", 1).
        
        oError = transactionApi:createLine(debetLine, FALSE, TRUE).
        IF oError <> "" THEN UNDO, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-DEBET;" + debetLine:account, 1).
     
    END.
    /* validate ballanced */

END.
*/

form    t_Header_Id FORMAT ">>>>>>>>>9" no-label at 2 
        transaction_header.balance_date no-label at 13
        transaction_header.create_user no-label at 24 
        transaction_header.deal_number NO-LABEL AT 35
    with frame header_form row 2 overlay title 
    "Transaction Date       Create     Deal Reference                              ".
    
form    atl label "BAL" to 27 
        deb label "TOTAL DR" to 54 
        kre label "TOTAL CR" to 79
    with frame cc1 row 5 side-labels overlay no-box.
    
form    line no-label 
        glkon no-label 
        gl.short_name  FORMAT "x(20)" no-label 
        currency no-label 
        t_Account no-label SKIP
        account_name no-label format "x(33)"
        debet no-label to 59 
        credit no-label to 78 skip
    with frame cc3 ROW 6 scroll 4 4 down  overlay title
    "Line G/L account                   CRC SubAccount    Debet             Credit".
form
    details label "Details" at 2 skip
    with frame cc4 row 16 side-labels no-box overlay.


if key = 2 then do :
     oError = transactionApi:createHeader(INPUT-OUTPUT trHeader). /* Make method with da~ta   */ 
    
    update t_Header_Id validate (
        can-find(transaction_header where transaction_header.header_id = t_Header_Id 
                                      AND transaction_header.state NE 9 ), "Incorrect transaction Number !") 
        help "Transaction Number (F2 - HELP)" with frame header_form.
    
    FIND FIRST transaction_header where transaction_header.header_id = t_Header_Id no-error.
    
    display transaction_header.balance_date transaction_header.create_user 
    transaction_header.deal_number with frame header_form.
    
    for each transaction_line WHERE transaction_line.header_id = transaction_header.header_id AND transaction_line.state ne 9
        no-lock use-index header_id :
        line = transaction_line.line.
        glkon = transaction_line.gl.
        currency = transaction_line.currency.
        t_Account = transaction_line.account.
        details = transaction_line.details.
        debet = transaction_line.debet.
        credit = transaction_line.credit.
        find FIRST gl WHERE gl.gl = transaction_line.gl no-lock no-error.
        if gl.subled <> "" then do :
            FIND FIRST account WHERE account.account = transaction_line.account NO-LOCK NO-ERROR.
            IF AVAILABLE account THEN account_name = account.description.
        END.   
        else account_name = "".
        display line glkon gl.short_name currency t_Account with frame cc3. 
        display details with frame cc4.
        display account_name debet credit with frame cc3.
        deb = deb + debet.
        kre = kre + credit.
        atl = deb - kre.
        display atl deb kre with frame cc1.
        down with frame cc3.
    end.
    
    
end.



if key = 1 then do :
    /*************/
    oError = transactionApi:createHeader(INPUT-OUTPUT trHeader). /* Make method with data    */
    MESSAGE ">>>" trHeader:putDb().
    t_Header_Id= trHeader:header_id.
    
    find FIRST transaction_header where transaction_header.header_id = trHeader:header_id no-error.

    display t_Header_Id 
        with frame header_form.
        
    display transaction_header.balance_date 
            transaction_header.create_user 
            transaction_header.deal_number 
            with frame header_form.
            
    display atl deb kre 
        with frame cc1.
        
    view frame cc3.
    view frame cc4.
    PAUSE 200.
end.


repeat while i2 = 0 on endkey undo,retry:
    repeat while k = 0 on endkey undo,leave:
    
        MESSAGE "1-Add, 2-View, 3-Print, 4-Detele, 5-Authorize" update j.
        
        if j = 1 then do :
            /************
            oError = closedDaysApi:validBalanceDate(transaction_header.balance_date).
            IF oError <> "" THEN DO:
            ************/
            if transaction_header.balance_date le /****globalSettings:balance_date ****/ 06/12/2018 then do :
                MESSAGE oError + " Can't edit transaction !".
                pause 3.
                hide message no-pause.
            end.
            
            else do :
                                                       
                k1 = 0.
                
                repeat on endkey undo,leave :
                    deb = 0.0.
                    kre = 0.
                    for each transaction_line WHERE transaction_line.header_id = transaction_header.header_id AND transaction_line.state ne 9
                        no-lock use-index header_id :
                        deb = deb + transaction_line.debet.
                        kre = kre + transaction_line.credit.
                    end.
                    atl = deb - kre.
                    display atl deb kre with frame cc1.
                    m1 = 0.
                    m = 0.
                    line = int64("").
                    glkon = 0.
                    
                   
                    if atl > 0.0 then do :
                        credit = atl.
                        debet = 0.0.
                    end.
                    else  do :
                        debet = - atl.
                        credit = 0.0.
                    end.
                    if key = 2 or j1 <> 0 then do :
                        down with frame cc3.
                        j1 = 1.
                    end.
                    
                    set line validate(line < 1000,"") with frame cc3.
                    j1 = 1.
                    /***********/ 
                    trLine  = transactionApi:createLineModel(trHeader).
                    trLine:EMPTY().
                    /********/
                    dop1 = 0.
                    if line <> int64("") 
                    THEN DO:
                    /*******************/
                        oError = trLine:getDbByHeaderLine(transaction_header.header_id , line).
                        if oError <> ""  
                        THEN DO:
                            trLine:empty().
                            trLine:line = line.
                        END.
                        ELSE DO: 
                            /*Existent line */       
                            dop1 =  1.
                        END.
                    END.
                    ELSE DO:
                        line = transactionCore:getValidTransactionLine(t_Header_Id, line).
                        trLine:line = line.
                        ASSIGN sost2 = 1.
                    END.  
                    display line  with frame cc3.
                    ASSIGN  glkon    = trLine:gl
                            t_Account  = trLine:account
                            currency = trLine:currency
                            details  = trLine:details
                            debet    = trLine:debet
                            credit   = trLine:credit
                            trx_date = trLine:balance_date.                    
                    IF  currency = "" THEN currency = "EUR". /*!!! currencyApi:nationalCurrency.*/
                        /*
                        tmpDC tmpAmount tmpCurrency tmpDetails
        UPDATE tmpGl tmpDC tmpAmount THEN tmpCurrency tmpDetails.
        
                        find first transaction_line where transaction_line.transaction_header = transaction_header.header_id and
                        transaction_line.ln = line AND transaction_line.state <> 9 no-error.
                        if available transaction_line then do :
                            MESSAGE "Can't enter existent line number!".
                            
                            dop1 = 1. /*Existent line */
                            
                            line = transaction_line.ln.
                            glkon = transaction_line.gl.
                            currency = transaction_line.currency.
                            t_Account = transaction_line.acc.
                            details = transaction_line.details.
                            
                            debet = transaction_line.dam.
                            credit = transaction_line.cam.
                            
                        end.
                        else do :
                            dop1 = 0.
                            glkon = 0.
                            currency = baseCrc.
                            t_Account = "".
                            sost2 = 1.
                        end.
                    end.
                    else do :
                        line = transactionCore:getValidTransactionLine(t_Header_Id,line).
                        display line  with frame cc3.
                        glkon = 0.
                        currency = baseCrc.
                        t_Account = "".                        sost2 = 1.
                        dop1 = 0.
                    end.
                    */
                    repeat while m = 0 ON ENDKEY UNDO, LEAVE:
                        update glkon 
                        
                        validate(can-find(gl where gl.gl = glkon AND gl.gl_status NE "CLOSED"),
                        "Incorrect or Inactive GL Account !!!")
                        
                        with frame cc3.
                        find gl where gl.gl = glkon no-lock no-error.
                        if available gl then m = 1.
                        /*
                        else do :
                            up with frame cc3.
                        end.
                        */
                    end.
                    
                    if m = 1 then do :
                        display gl.short_name with frame cc3.
                           
                        repeat while j2 = 0 ON ENDKEY UNDO, LEAVE:
                            update currency
                            validate (can-find(currency where currency.currency = currency AND currency.state NE 9),
                            "Incorrect Currency !") with frame cc3.
                            
                            find first currency where currency.currency eq currency no-lock no-error.
                            j2 = 1.
                        END.    
                        if j2 = 0 then do :
                            up with frame cc3.
                            /********
                            LEAVE.
                            ********/
                        end.
                        else j2 = 0.
                             
                        repeat while i = 0 on endkey undo ,leave :
                            IF gl.subledger_type NE "" THEN DO:
                                UPDATE t_Account VALIDATE(CAN-FIND(account WHERE account.account = t_Account AND account.gl = glkon AND account.currency = currency),"")
                                WITH FRAME cc3.
                                /*********************/
                                oError = transactionCore:validateTransactionAccount(glkon, t_Account, currency,"").
                                /*****************/
                                IF oError <> "" THEN NEXT.
                                ELSE i = 1.
                            END.
                            ELSE i = 1.
                            IF t_Account NE "" THEN DO:
                                FIND FIRST account WHERE account.account = t_Account NO-LOCK NO-ERROR.
                                account_name = account.description.
                            END.    
                            display account_name with frame cc3.
                        end.
                        if i = 0 then DO:
                            up with frame cc3.
                            leave.
                        end.
                        else i = 0.
                                         
                        repeat while j3 = 0 :
                            update details with frame cc4.
                            j3 = 1.
                        end.
                        if j3 = 0 then do :
                            up with frame cc3.
                            leave.
                        end.
                        else j3 = 0.
                                                
                        blk:
                        repeat while m1 = 0 on endkey undo,leave :
                            update debet VALIDATE (debet ge 0.0 , "Must be > 0 !" )
                                with frame cc3.
                                
                            debet = round(debet,currency.decimal_points).
                            display debet with frame cc3.
                            if debet = 0.0 then do :
                                update credit
                                validate (credit ge 0.0 ,"Must be > 0 !" )
                                with frame cc3.
                                credit = round(credit,currency.decimal_points).
                                display credit with frame cc3.
                                if credit > 0.0 then do :
                                    debet = 0.0.
                                    t_DC = "C".
                                    display debet with frame cc3.
                                    m1 = 1.
                                end.
                            end.
                            else do :
                                t_DC = "D".
                                credit = 0.0.
                                display credit with frame cc3.
                                m1 = 1.
                            end.
                        end.
                    end.
                    else do :
                        up with frame cc3.
                    end.
                    
                    
                            
                    if m = 1 and m1 = 1 then do :
                        cr2:
                        DO TRANSACTION:   

                            /*************/
                            if sost2 = 1 and dop1 = 1 then do :
                                oError = transactionApi:DeleteLine(t_header_id, line, NO, NO).
                                IF oError <> "" THEN DO:
                                    UP WITH FRAME cc3.
                                    UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";CAN'T-DELETE-OLD-NAME", 1).
                                END.        
                            END. 
                        
                            oError = trLine:setLineData(trx_date, glkon, t_Account, t_DC, MAXIMUM(debet,credit), currency, details).
                            IF oError <> "" THEN DO:
                                UP WITH FRAME cc3.
                                UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-LINE-DATA", 1).
                            END.    
        
                            oError = transactionApi:createLine(trLine, FALSE, TRUE).
                            IF oError <> "" THEN DO:
                                UP WITH FRAME cc3.
                                UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-LINE;", 1).
                            end.
                            /***********/
                        END.
                    END.
                    else do :
                        up with frame cc3.
                    end.
                   
                    dop1 = 0.
                    m = 0.
                    m1 = 0.
                    key = 2.
                    sost2  = 0.
                 
                end.
            end.
            k = 0.
            if i = 0 then do :
                up with frame cc3.
            end.
        end.
        
        
        
        /*
        if j = 2 then do :
            t_Header_Id= transaction_header.
            run vw_jjhr.
            k = 0.
        end.
        if j = 3 then do :
            t_Header_Id =  transaction_header.
            run x-jlvou.r.
            k = 0.
        end.
        if j = 4 then do :
            m2 = 0.
            i1 = 0.
            repeat while i1 = 0 :
                message "1 --> Delete Line  2 --> Delete All Transaction"
                update m2.
                if m2 = 1 then do :
                
                                   
                   t_Header_Id = transaction_header.
                    run d_xjl1.r.
                    clear frame cc3 no-pause.
                    up 6 with frame cc3.
                    hide all no-pause.
                    run vw_transaction_header.r.
                    up 6 with frame cc3.
                    clear all no-pause.
                    k = 0.
                    i1 = 1.
                    clear all no-pause.
                end.
                if m2 = 2 then do :
                    t_Header_Id= transaction_header.
                    run d_xjjhxr(output sost3).
                    if sost3 = 1 then do :
                        k = 1.
                        i1 = 1.
                        i2 = 1.
                    end.
                    else do :
                        i1 = 0.
                    end.
                end.
            end.
            if m2 = 0 then k = 0.
        end.
        if j = 5 then do :
            run jl_st1x.r.
            k = 0.
        end.
        */
    end.
    
    if k <> 1  then do :
        
        RUN check_ubal(t_Header_Id, OUTPUT ubkey).
                
        if ubkey = yes then do :
            message "Unbalanced transaction!".
            pause 3.
            repeat while i3 = 0 on endkey undo,leave :
                message "Keep it ?" update ques2.
                if ques2 = no then do:
                    i2 = 0.
                    i3 = 1.
                    k = 0.
                end.
                
            end.
            if i3 = 0 then do :
                i2 = 0.
                k = 0.
            end.
            i3 = 0.
        end.
        else i2 = 1.
    end.
    
end.
hide all no-pause.

PROCEDURE check_ubal:
    DEFINE INPUT PARAMETER header_id AS INT64.
    DEFINE OUTPUT PARAMETER ubkey AS LOG INITIAL NO.

    EMPTY TEMP-TABLE totbal.

    for each transaction_line where transaction_line.header_id = header_id no-lock :
        find first gl where gl.gl = transaction_line.gl no-lock no-error.
        if gl.parent <> 300000 and gl.parent <> 600000 then do :
            find first totbal where totbal.currency = transaction_line.currency NO-ERROR.
            IF NOT AVAILABLE totbal THEN DO:
                CREATE totbal.
                ASSIGN totbal.currency = transaction_line.currency.
            END.    
            totbal.debet = totbal.debet + transaction_line.debet.
            totbal.credit = totbal.credit + transaction_line.credit.
        END.    
    end.
    
    FOR EACH totbal WHERE totbal.debet NE totbal.credit :
        ubkey = YES.
    END.    
END.    

/*
procedure cda_chkc :    
        if baa3.pass = "U" then do :
            strx = substr(string(baa3.lstmgbal,"999999999999999999999"),14,8). 
            if strx ne "00000000" then do :
                mdat = date(int(substr(strx,5,2)),int(substr(strx,7,2)),
                int64(substr(strx,1,4))).
                if mdat < g-today then do :
                    message 
           "Превышен максимальный срок пополнения универсального депозита !".
                    pause 3.
                    hide message no-pause.
                end.
                else do:
                  debet = 0.0.
                  t_DC = "C".
                  display debet with frame cc3.
                  m1 = 1.
                end.
            end.
            else do :
                debet = 0.0.
                t_DC = "C".
                display debet with frame cc3.
                m1 = 1.
            end.
        end.    
        else if (baa3.regdt > 05/14/2000 and baa3.pass = "T") 
            or baa3.pass = "K" then do :
            find dpdeal where dpdeal.dpdeal = baa3.aaa no-lock no-error.
            if not available dpdeal or dpdeal.tim = 0 then do :
            
                if dpdeal.tim = 0 then do :
                  run idepo_lgr.p(baa3.aaa,output idepoind).
                  if idepoind ne 0 then do:
                    message "Не возможно пополнять IDEPO депозит !".
                    pause 3.
                    hide message no-pause.
                  end.
                end.
      
                if baa3.pass = "K" or baa3.pass = "T" then dx2 = baa3.regdt.
                else do :
                    run nx_dt(baa3.regdt,output dx1).
                    run nx_dt(dx1,output dx2).
                end.
                find first dpgrp where
                  dpgrp.dpgrp eq dpdeal.grp and
                ( dpgrp.dpgrp eq 21 or
                  dpgrp.dpgrp eq 22 ) no-lock no-error.
                if not available dpgrp and
                  (( baa3.expdt - baa3.regdt < 32 and
                       g-today > baa3.regdt ) or
                   ( baa3.expdt - baa3.regdt > 31 and
                       g-today > dx2 )) then do :
                    message  
                    "Превышен максимальный срок внесения депозита !".  
                    pause 3.
                    hide message no-pause.
                end. 
                else if g-today ge baa3.expdt then do :
                    message 
                    "Превышен максимальный срок внесения депозита !".
                    pause 3.
                    hide message no-pause.
                end.
                else 
                if ost7x + credit > baa3.opnamt then do :
                    message "Превышена сумма по депозитному договору !".
                    pause 3.
                    hide message no-pause.
                end.
                else do :
                    find first dpdeal where dpdeal.dpdeal = baa3.aaa no-error.
                    if available dpdeal and dpdeal.grp ne 1 then do :
                        if dpdeal.sts < 5 then do :
                            dpdeal.sts = 5.
                            dpdeal.vtransaction_header = transaction_headerx.
                        end.    
                    end.    
                    debet = 0.0.
                    t_DC = "C".
                    display debet with frame cc3.
                    m1 = 1.
                end.
            end.    
            else do :
                find first dpdeal where dpdeal.dpdeal = baa3.aaa no-error.
                if available dpdeal and dpdeal.grp ne 1 then do :
                    if dpdeal.sts < 5 then do :
                        dpdeal.sts = 5.
                        dpdeal.vtransaction_header = transaction_headerx.
                    end.    
                end.    
                debet = 0.0.
                t_DC = "C".
                display debet with frame cc3.
                m1 = 1.
            end.
        end.
        /*
        else if baa3.regdt le 05/14/2000 and baa3.pass = "T" then do :
            message 
            "Превышен максимальный срок внесения срочного депозита !".
            pause 3.
            hide message no-pause.
        end.
        */
        else do :
            debet = 0.0.
            t_DC = "C".
            display debet with frame cc3.
            m1 = 1.
        end.
end procedure.
*/
/*
DELETE_OBJECTS_MLAAD().
*/