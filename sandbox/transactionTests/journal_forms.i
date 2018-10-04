
DEFINE VARIABLE t_header_id   AS INT64   FORMAT ">>>>>>>>>9".

DEFINE FRAME header_form 
        t_header_id                      FORMAT ">>>>>>>>>9" AT 2 NO-LABEL
        transaction_header.balance_date  FORMAT "99.99.9999" 
        transaction_header.create_user   FORMAT "X(8)"       
        transaction_header.deal_number   FORMAT "X(10)"      
    WITH OVERLAY ROW 2 NO-LABELS SIZE-CHARS 80 BY 3
    TITLE "Transaction Date       Create     Deal Reference                              ".


DEFINE VARIABLE t_tot_balance AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99-".
DEFINE VARIABLE t_tot_debet   AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
DEFINE VARIABLE t_tot_credit  AS DECIMAL FORMAT "zzz,zzz,zz9.99-".
    
FORM    t_tot_balance   LABEL "BAL"      FORMAT "->,>>>,>>>,>>9.99" 
        t_tot_debet     LABEL "TOTAL DR" FORMAT ">,>>>,>>>,>>9.99" 
        t_tot_credit    LABEL "TOTAL CR" FORMAT ">,>>>,>>>,>>9.99" 
    WITH FRAME balances_form OVERLAY ROW 5 SIDE-LABELS SIZE-CHARS 80 BY 3 NO-BOX.
    
DEFINE VARIABLE t_details       AS CHARACTER FORMAT "x(65)".
DEFINE VARIABLE t_line          AS INTEGER   FORMAT "9999".
DEFINE VARIABLE t_gl            AS INTEGER   FORMAT ">>>>>>>>".
DEFINE VARIABLE t_account       AS CHARACTER FORMAT "x(12)" /*case-sensitive*/ .
DEFINE VARIABLE t_currency      AS CHARACTER FORMAT "x(3)".
DEFINE VARIABLE t_gl_name       AS CHARACTER FORMAT "X(16)".
DEFINE VARIABLE t_account_name  AS CHARACTER FORMAT "X(30)".
DEFINE VARIABLE t_debet         AS DECIMAL   FORMAT "zz,zzz,zz9.99".
DEFINE VARIABLE t_credit        AS DECIMAL   FORMAT "zz,zzz,zz9.99".

FORM    t_line 
        t_gl   
        t_gl_name  
        t_currency 
        t_account SKIP
        t_account_name
        t_debet  to 57 
        t_credit to 76
    WITH frame trline_form OVERLAY ROW 6 SCROLL 4 DOWN SIZE-CHARS 80 BY 10 NO-LABELS
    TITLE "Line G/L account                   CRC SubAccount    Debet             Credit".
    
FORM    t_details LABEL "Details" AT 2 
    with frame details_form OVERLAY ROW 16 SIDE-LABELS SIZE-CHARS 80 BY 2 NO-BOX.

    
FUNCTION showHeaderForm CHARACTER ():
    CLEAR FRAME header_form. 
    PAUSE 0.
    
    VIEW  FRAME header_form. 
    PAUSE 0.
    
    DISPLAY t_header_id WITH FRAME header_form. 
    PAUSE 0.
    
    IF AVAILABLE transaction_header 
    THEN DO:
        DISPLAY transaction_header.balance_date 
                transaction_header.create_user
                transaction_header.deal_number
                WITH FRAME header_form.
        PAUSE 0.
    END.
END.

FUNCTION showBalancesForm CHARACTER ():
    t_tot_balance = t_tot_debet - t_tot_credit.
    
    DISPLAY t_tot_balance t_tot_debet t_tot_credit 
        WITH FRAME balances_form.
    PAUSE 0.
END.

FUNCTION showTrLineForm CHARACTER ():
    DISPLAY 
        t_line 
        t_gl   
        t_gl_name  
        t_currency 
        t_account 
        t_account_name AT 1
        t_debet  
        t_credit  
        WITH FRAME trline_form.
    PAUSE 0.
    
            /*
        display line glkon gl.short_name currency t_Account with frame cc3. 
        display account_name debet credit with frame cc3.
        down with frame cc3.
        */
END.

FUNCTION showDetailsForm CHARACTER ():
    DISPLAY t_details 
        WITH FRAME details_form.
    PAUSE 0.
END.

FUNCTION clearAllForms CHARACTER ():
    hide all no-pause.
    CLEAR FRAME header_form. 
    PAUSE 0.
    CLEAR FRAME balances_form. 
    PAUSE 0.
    CLEAR FRAME trline_form. 
    PAUSE 0.
    CLEAR FRAME details_form. 
    PAUSE 0.
END.


/* TODO Move to core */
DEFINE TEMP-TABLE totbal NO-UNDO
    FIELD currency AS CHARACTER
    FIELD debet AS DECIMAL
    FIELD credit AS DECIMAL
    INDEX currency currency ASC.
    
FUNCTION isBalancedTransaction  LOG(i_header_id AS INT64):
    DEFINE BUFFER transaction_line FOR transaction_line.
    
    EMPTY TEMP-TABLE totbal.    
    FOR EACH transaction_line WHERE transaction_line.header_id = header_id no-lock :
        find first gl where gl.gl = transaction_line.gl no-lock no-error.
        if gl.parent <> 300000 and gl.parent <> 600000 then do :
            find first totbal where totbal.currency = transaction_line.currency NO-ERROR.
            IF NOT AVAILABLE totbal THEN DO:
                CREATE totbal.
                ASSIGN totbal.currency = transaction_line.currency.
            END.    
            totbal.debet  = totbal.debet  + transaction_line.debet.
            totbal.credit = totbal.credit + transaction_line.credit.
        END.    
    END.
    
    FOR EACH totbal WHERE totbal.debet NE totbal.credit :
        RETURN FALSE.
    END.
    
    RETURN TRUE.
END.