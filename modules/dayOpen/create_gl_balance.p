USING system.api.systemSettings.*.

/*
    Ceate balances for current open date
    Warning! Not supports new currency addition in already opened day.
*/

/*CURRENT-VALUE(gl_balance_id) = 1000.*/

DISPLAY globalSettings:balance_date.
PAUSE.

FOR EACH gl NO-LOCK:
    find first gl_balance where gl_balance.gl = gl.gl AND gl_balance.balance_date EQ globalSettings:balance_date
    no-lock no-error.
    if not available gl_balance then do:
        for each currency where currency.state ne 9 no-lock:
            create gl_balance.

            assign 
                  gl_balance.gl             = gl.gl
                  gl_balance.currency       = currency.currency
                  gl_balance.balance_date   = globalSettings:balance_date
                  .
        END.
    END.
END.