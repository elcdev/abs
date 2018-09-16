RUN startupSettings.p. 

FOR EACH transaction_header:
    DELETE transaction_header.
END.

FOR EACH transaction_line:
    DELETE transaction_line.
END.

FOR EACH payments:
    DELETE payments.
END.

FOR EACH account_balance_future:
    DELETE account_balance_future.
END.

MESSAGE "all transaction are deleted".
PAUSE.