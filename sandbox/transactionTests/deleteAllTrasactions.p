RUN startupSettings.p. 

FOR EACH transaction_header:
    DELETE transaction_header.
END.

FOR EACH transaction_line:
    DELETE transaction_line.
END.

MESSAGE "all transaction are deleted".
PAUSE.