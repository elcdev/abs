USING system.api.core.*.
USING system.api.balance.*.
USING Progress.IO.*.

/*
FOR each account:
    disp id account_status account.account currency LENGTH(currency) WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
end. 
*/

RUN startupSettings.p. 
/* RUN create_gl_balance.p. */

/*
FOR EACH gl WHERE gl.gl = 11402600:
    UPDATE gl.
END. 
*/
/*
MESSAGE SUBSTITUTE("[[Payment fee for &1]]", "gggg") VIEW-AS ALERT-BOX.
*/
DEFINE VARIABLE json        AS LONGCHAR.
DEFINE VARIABLE tAccount    AS accountModel.
DEFINE VARIABLE cAccount    AS accountModel.
tAccount = NEW accountModel().

tAccount:getDb(1).
tAccount:account = "C00000000004".
tAccount:currency = "USD".
MESSAGE STRING(tAccount:toJson()) VIEW-AS ALERT-BOX.

/*COPY-LOB tAccount:toJson() TO FILE "test.json".*/

/*COPY-LOB FILE "test.json" TO json.*/


/*cAccount = accountModel:parseJson(json).*/
/*cAccount:SERIALIZE-NAME = "account".*/
cAccount = accountModel:parseJsonFile("test.json").
/*

MESSAGE STRING(cAccount:toJson()) VIEW-AS ALERT-BOX.
*/
/*
tAccount:id = 0.
tAccount:account = "C00000000004".
tAccount:currency = "USD".
tAccount:base_account = tAccount:account.
tAccount:description = "Test account in usd".
MESSAGE tAccount:putDb() VIEW-AS ALERT-BOX.
*/

/*
FOR EACH payments:
    DISPLAY payments WITH 1 COLUMN SIZE 80 BY 25.
    PAUSE.
END.
*/
/*
FOR EACH transaction_line:
    DISPLAY  transaction_line.header_id  balance_date transaction_line.id gl account debet credit WITH WIDTH 300. /*WITH 1 COLUMN SIZE 80 BY 25.*/
END.
PAUSE.

*/
/*
FOR EACH account_balance WHERE account = "C00000000004":
    DISPLAY account_balance WITH WIDTH 500 . /*1 COLUMN SIZE 80 BY 20.*/
    PAUSE.
END.
*/
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
FOR EACH gl_balance WHERE balance_date = 09/12/2018
    AND gl = 30311000:
    DISPLAY gl_balance WITH 1 COLUMN SIZE 80 BY 20.
    PAUSE.
END.
*/