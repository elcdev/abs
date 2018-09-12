RUN startupSettings.p.  

CREATE currency.
UPDATE currency.

FOR EACH currency:
    DISPLAY currency.id currency.currency.
END.

PAUSE.

/*
CREATE account.
account.gl = 100000.
account.account = "A100000".
account.iban = account.account.
account.currency = "EUR".


CREATE account.
account.gl = 200000.
account.account = "A200000".
account.iban = account.account.
account.currency = "EUR".
*/
PAUSE.