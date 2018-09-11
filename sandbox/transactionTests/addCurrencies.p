RUN startupSettings.p.  

CREATE currency.
UPDATE currency.

FOR EACH currency:
    DISPLAY currency.id currency.currency.
END.

PAUSE.