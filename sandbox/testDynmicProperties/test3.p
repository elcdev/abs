/*
FOR each account:
    disp id account_status account.account currency LENGTH(currency) WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
end. 
*/

RUN startupSettings.p. 
/*
MESSAGE SUBSTITUTE("[[Payment fee for &1]]", "gggg") VIEW-AS ALERT-BOX.
*/
/*
DEFINE VARIABLE tAccount AS accountModel.
tAccount = NEW accountModel().

tAccount:getDb(2).
tAccount:id = 0.
tAccount:account = "C00000000003".
tAccount:base_account = tAccount:account.
tAccount:description = "Test account for client 2".
MESSAGE tAccount:putDb() VIEW-AS ALERT-BOX.
*/

/*
FOR EACH payments:
    DISPLAY payments WITH 1 COLUMN SIZE 80 BY 25.
    PAUSE.
END.
*/
 
FOR EACH transaction_line:
    DISPLAY  transaction_line.header_id transaction_line.id gl account debet credit WITH WIDTH 300. /*WITH 1 COLUMN SIZE 80 BY 25.*/
END.
PAUSE.


FOR EACH account_balance WHERE account = "123456789012":
    DISPLAY account_balance WITH WIDTH 500 . /*1 COLUMN SIZE 80 BY 20.*/
    PAUSE.
END.

/*
FOR EACH account_balance_future:
    DISPLAY account_balance_future  WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
END.
*/
/*
FOR EACH currency:
    DISPLAY currency.
    PAUSE.
END.
*/
/*
FOR EACH gl:

    DISPLAY gl WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
        
END.
*/
/*
FOR EACH gl_balance:
    DISPLAY gl_balance WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
END.
*/