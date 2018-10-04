USING system.api.core.*.
USING system.api.balance.*.
USING system.api.systemSettings.*.
USING system.api.currency.*.

DEFINE INPUT PARAMETER chooseNewOld AS INT64.

{journal_forms.i}
DEFINE VARIABLE development AS LOGICAL INITIAL TRUE. /* FALSE on prod - TODO. Move to global vars*/

DEFINE VARIABLE oError AS CHARACTER.
define variable chooseAction  as int64 format "9" initial 0.

define variable j1 as int64 format "9" initial 0.
define variable j2 as int64 format "9" initial 0.
define variable j3 as int64 format "9" initial 0.
define variable i1 as int64 format "9" initial 0.
define variable waitEditing as int64 format "9" initial 0.
define variable i3 as int64 format "9" initial 0.
define variable m  as int64 format "9" initial 0.
define variable m1 as int64 format "9" initial 0.
define variable m2 as int64 format "9" initial 0.
define variable waitEditLine  as int64 format "9" initial 0.
define variable k1 as int64 format "9" initial 0.
define variable dop1 as int64 initial 0.
define variable sost as int64.
define variable sost2 as int64.
define variable t_DC like transaction_line.dc.
define variable i as int64 initial 0.
def var k2 as int64.
def var debx as dec extent 50.
def var krex as dec extent 50.
define variable ques as logical format "Yes/No" initial no.


define variable trx_date AS DATE. 


DEFINE VARIABLE id AS INT64.

/********/
DEFINE VARIABLE trHeader  AS transactionHeaderModel.
DEFINE VARIABLE trLine    AS transactionLineModel.

IF chooseNewOld = 2 /* View existing */
THEN DO:
    oError = transactionApi:createHeader(INPUT-OUTPUT trHeader). /* Make method with da~ta   */ 
    
    UPDATE t_Header_Id VALIDATE (
        CAN-FIND(transaction_header WHERE transaction_header.header_id = t_Header_Id 
                                      AND transaction_header.state NE 9 ), "Incorrect transaction Number !") 
        HELP "Transaction Number (F2 - HELP)" 
        WITH FRAME header_form.
    
    FIND FIRST transaction_header WHERE transaction_header.header_id = t_Header_Id NO-ERROR.
    
    showHeaderForm().
        
    FOR EACH transaction_line WHERE transaction_line.header_id = transaction_header.header_id 
                                AND transaction_line.state ne 9
                    NO-LOCK USE-INDEX header_id:
        t_line      = transaction_line.line.
        t_gl        = transaction_line.gl.
        t_currency  = transaction_line.currency.
        t_Account   = transaction_line.account.
        t_details   = transaction_line.details.
        t_debet     = transaction_line.debet.
        t_credit    = transaction_line.credit.
        t_account_name = "".
        
        /* TODO Move to core */
        FIND FIRST gl WHERE gl.gl = transaction_line.gl NO-LOCK NO-ERROR.
        IF AVAILABLE gl THEN  t_gl_name = gl.short_name.

        FIND FIRST account WHERE account.account = transaction_line.account NO-LOCK NO-ERROR.
        IF AVAILABLE account THEN t_account_name = account.description.

        t_tot_debet     = t_tot_debet  + transaction_line.debet.
        t_tot_credit    = t_tot_credit + transaction_line.credit.
        
        showDetailsForm().
        showBalancesForm().
        showTrLineForm().
    END.
END.



IF chooseNewOld = 1 
THEN DO:
    /*************/
    oError = transactionApi:createHeader(INPUT-OUTPUT trHeader). /* Make method with data    */
    IF oError <> "" THEN UNDO, RETURN.
    
    oError = trHeader:putDb().
    IF oError <> "" THEN UNDO, RETURN.
    /* TODO revrite */
    t_Header_Id= trHeader:header_id.
    
    FIND FIRST transaction_header WHERE transaction_header.header_id = trHeader:header_id NO-ERROR.

    showHeaderForm().
    showDetailsForm().
    showBalancesForm().
    showTrLineForm().
END.

startEditing:
REPEAT WHILE waitEditing = 0 ON ENDKEY UNDO, RETRY:
    REPEAT WHILE waitEditLine = 0 ON ENDKEY UNDO, LEAVE:
        MESSAGE "1-Add, 2-View, 3-Print, 4-Detele, 5-Authorize, 6-Exit" UPDATE chooseAction.
        IF chooseAction = 6 THEN LEAVE startEditing.
        
        IF chooseAction = 1 
        THEN DO: 
            /************
            oError = closedDaysApi:validBalanceDate(transaction_header.balance_date).
            IF oError <> "" THEN DO:
            ************/
            IF transaction_header.balance_date le globalSettings:balance_date AND NOT development 
            THEN DO:
                MESSAGE oError + " Can't edit transaction !".
                PAUSE 3.
                HIDE MESSAGE NO-PAUSE.
                RETRY.
            END.
            
            k1 = 0.
                
            REPEAT ON ENDKEY UNDO, LEAVE:
                t_tot_debet  = 0.0.
                t_tot_credit = 0.0.
                FOR EACH transaction_line WHERE transaction_line.header_id = t_Header_Id AND transaction_line.state ne 9
                    NO-LOCK USE-INDEX header_id :
                    t_tot_debet  = t_tot_debet  + transaction_line.debet.
                    t_tot_credit = t_tot_credit + transaction_line.credit.
                END.
                showBalancesForm().
                
                /* DOWN WITH FRAME trline_form. */
                m1 = 0.
                m = 0.
                t_line = 0.
                t_gl   = 0.
                
                /* Remained balance */
                IF t_tot_balance > 0.0 
                THEN DO:
                    t_credit = t_tot_balance.
                    t_debet  = 0.0.
                END.
                ELSE DO:
                    t_debet  = - t_tot_balance.
                    t_credit = 0.0.
                END.
                
                IF chooseNewOld = 2 OR j1 <> 0 
                THEN DO:
                    DOWN WITH FRAME trline_form.
                    j1 = 1.
                END.
                
                UPDATE t_line VALIDATE(t_line < 1000, "") WITH FRAME trline_form.
                j1 = 1.
                trLine  = transactionApi:createLineModel(trHeader).

                dop1 = 0.
                IF t_line <> 0
                THEN DO:
                /*******************/
                    oError = trLine:getDbByHeaderLine(transaction_header.header_id , t_line).
                    if oError <> ""  
                    THEN DO:
                        trLine:empty(). /* ??? Realy need */
                        trLine:line = t_line.
                    END.
                    ELSE DO: 
                        /*Existent line */       
                        dop1 =  1.
                    END.
                END.
                ELSE DO:
                    t_line = transactionCore:getValidTransactionLine(t_Header_Id, t_line).
                    trLine:line = t_line.
                    ASSIGN sost2 = 1.
                END.  
                
                showTrLineForm().
                
                ASSIGN  t_gl      = trLine:gl
                        t_Account = trLine:account
                        t_currency= trLine:currency
                        t_details = trLine:details
                        t_debet   = trLine:debet
                        t_credit  = trLine:credit
                        trx_date  = trLine:balance_date.
                
                IF  t_currency = "" THEN t_currency = currencyApi:nationalCurrency.
                    
                REPEAT WHILE m = 0 ON ENDKEY UNDO, LEAVE:
                    UPDATE t_gl 
                        VALIDATE(CAN-FIND(gl WHERE gl.gl = t_gl AND gl.gl_status NE "CLOSED"),
                                "Incorrect or Inactive GL Account !!!")
                        WITH FRAME trline_form.
                    
                    FIND gl WHERE gl.gl = t_gl NO-LOCK NO-ERROR.
                    IF AVAILABLE gl THEN m = 1.
                    /*
                    else do :
                        up with frame trline_form.
                    end.
                    */
                END.
                
                IF m = 1 
                THEN DO:
                    showTrLineForm().
                       
                    REPEAT WHILE j2 = 0 ON ENDKEY UNDO, LEAVE:
                        update t_currency
                        validate (can-find(currency where currency.currency = t_currency AND currency.state NE 9),
                        "Incorrect Currency !") with frame trline_form.
                        
                        find first currency where currency.currency eq t_currency no-lock no-error.
                        j2 = 1.
                    END.    
                    if j2 = 0 then do :
                        up with frame trline_form.
                        /********
                        LEAVE.
                        ********/
                    end.
                    else j2 = 0.
                         
                    repeat while i = 0 on endkey undo ,leave :
                        IF gl.subledger_type NE "" THEN DO:
                            UPDATE t_Account VALIDATE(CAN-FIND(account WHERE account.account = t_Account AND account.gl = t_gl AND account.currency = currency),"")
                            WITH FRAME trline_form.
                            /*********************/
                            oError = transactionCore:validateTransactionAccount(t_gl, t_Account, t_currency, "").
                            /*****************/
                            IF oError <> "" THEN NEXT.
                            ELSE i = 1.
                        END.
                        ELSE i = 1.
                        IF t_Account NE "" THEN DO:
                            FIND FIRST account WHERE account.account = t_Account NO-LOCK NO-ERROR.
                            t_account_name = account.description.
                        END.    
                        showTrLineForm().
                    end.
                    if i = 0 then DO:
                        up with frame trline_form.
                        leave.
                    end.
                    else i = 0.
                                     
                    repeat while j3 = 0 :
                        update t_details with frame details_form.
                        j3 = 1.
                    end.
                    if j3 = 0 then do :
                        up with frame trline_form.
                        leave.
                    end.
                    else j3 = 0.
                                            
                    blk:
                    repeat while m1 = 0 on endkey undo, leave :
                        update t_debet VALIDATE (t_debet ge 0.0 , "Must be > 0 !" )
                            with frame trline_form.
                            
                        t_debet = ROUND(t_debet, currency.decimal_points).
                        showTrLineForm().
                        IF t_debet = 0.0 
                        THEN DO:
                            UPDATE t_credit
                                VALIDATE (t_credit ge 0.0 ,"Must be > 0 !" )
                                with frame trline_form.
                            t_credit = ROUND(t_credit, currency.decimal_points).
                            
                            IF t_credit > 0.0 
                            THEN DO:
                                t_debet = 0.0.
                                t_dc = "C".
                                m1 = 1.
                            END.
                        END.
                        ELSE DO:
                            t_dc = "D".
                            t_credit = 0.0.
                            m1 = 1.
                        END.
                        showTrLineForm().
                    END.
                END.
                ELSE DO:
                    UP WITH FRAME trline_form.
                END.
                
                
                        
                IF m = 1 and m1 = 1 
                THEN DO:
                    cr2:
                    DO TRANSACTION:   

                        /*************/
                        if sost2 = 1 and dop1 = 1 then do :
                            oError = transactionApi:DeleteLine(t_header_id, t_line, NO, NO).
                            IF oError <> "" THEN DO:
                                UP WITH FRAME trline_form.
                                UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";CAN'T-DELETE-OLD-NAME", 1).
                            END.        
                        END. 
                    
                        oError = trLine:setLineData(trx_date, t_gl, t_account, t_dc, MAXIMUM(t_debet, t_credit), t_currency, t_details).
                        IF oError <> "" THEN DO:
                            UP WITH FRAME trline_form.
                            UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";IN-SET-LINE-DATA", 1).
                        END.    

                        oError = transactionApi:createLine(trLine, FALSE, TRUE).
                        IF oError <> "" THEN DO:
                            UP WITH FRAME trline_form.
                            UNDO cr2, THROW NEW Progress.Lang.AppError (oError + ";IN-CREATE-LINE;", 1).
                        end.
                    END.
                END.
                ELSE DO:
                    UP WITH FRAME trline_form.
                END.
               
                dop1 = 0.
                m = 0.
                m1 = 0.
                chooseNewOld = 2.
                sost2  = 0.
            END.
            
            waitEditLine = 0.
            IF i = 0 
            THEN DO:
                UP WITH FRAME trline_form.
            END.

        END.
    END.
    
    IF waitEditLine <> 1  
    THEN DO:
        IF NOT isBalancedTransaction(t_Header_Id) 
        THEN DO:
            MESSAGE "Unbalanced transaction!".
            PAUSE 3.
            
            i3 = 0.
            
            REPEAT WHILE i3 = 0 ON ENDKEY UNDO, LEAVE:
                MESSAGE "Keep it ?" update ques.
                IF ques = no THEN DO:
                    i3 = 1.
                    waitEditing = 0.
                    waitEditLine = 0.
                END.
                /* TODO! A kak-zhe YES !? */
            END.
            
            IF i3 = 0 
            THEN DO:
                waitEditing = 0.
                waitEditLine = 0.
            END.
        END.
        ELSE waitEditing = 1.
    END.
END.

hide all no-pause.

    

