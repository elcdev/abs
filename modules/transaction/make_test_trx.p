define var trx_number AS INT64.

define var sost as int64.
define var mes as character format "x(75)".

DO TRANSACTION :
    run make_trx_header.p(07/25/2018,"user","", 0,"TEST DEAL", "LTH",6,"user",07/25/2018, output trx_number).
    oError = cTransactionApi:createHeader(INPUT-OUTPUT cTrHeader).
    
    DISPLAY trx_number.
    PAUSE.
    
    RUN mak_jlelc.p(trx_number, 10212000, "CBLT.EUR", 1, 500.0, 0.0, "Test transaction in ElCoin", "D", "EUR", 07/25/2018,
    "user", "",NO,YES, 6, "user", 07/25/2018, OUTPUT sost, OUTPUT mes).
    
    
    cTrDebetLine  = cTransactionApi:createLineModel(cTrHeader).
    oError = cTrDebetLine:setLineData("A100000", "D", 1000, "EUR", tDetails).
    oError = cTransactionApi:createLine(cTrDebetLine, NO, yes).
    
    IF sost = 0 THEN DO:
        DISPLAY mes FORMAT "x(70)".
        PAUSE.
        UNDO, RETURN.
    END.    

    RUN mak_jlelc.p(trx_number, 30311000, "123456789012", 2, 0.0, 500.0, "Test transaction in ElCoin", "C", "EUR", 07/25/2018,
    "user", "",NO,YES, 6, "user", 07/25/2018, OUTPUT sost, OUTPUT mes).
    IF sost = 0 THEN DO:
        DISPLAY mes FORMAT "x(70)".
        PAUSE.
        UNDO, RETURN.
    END.    
END.    