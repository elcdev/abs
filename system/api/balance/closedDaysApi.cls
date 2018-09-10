CLASS closedDaysApi:
    DEFINE STATIC PUBLIC VARIABLE ERROR-NOT-FOUND  AS CHARACTER INITIAL "BALANCE-DAY-NOT-FOUND".
    DEFINE STATIC PUBLIC VARIABLE ERROR-DAY-CLOSED AS CHARACTER INITIAL "BALANCE-DAY-CLOSED".
    
    CONSTRUCTOR STATIC closedDaysApi():
        Init().
    END.
    
    DESTRUCTOR closedDaysApi():
    
    END.
    
    METHOD STATIC PUBLIC CHARACTER Init():

        RETURN "".
    END.

    METHOD STATIC PUBLIC DATE getLastWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN today.

        RETURN closed_days.balance_date.
    END.

    METHOD STATIC PUBLIC CHAR openBalanceDate(iBalanceDate AS DATE):
        DEFINE BUFFER closed_days FOR closed_days.

        FIND LAST closed_days WHERE closed_days.balance_date = iBalanceDate NO-LOCK NO-ERROR.
        IF AVAILABLE closed_days THEN RETURN "".

        CREATE closed_days.
        closed_days.balance_date = iBalanceDate.
        closed_days.closed      = false.
        
        RETURN "".
    END.

    METHOD STATIC PUBLIC CHAR closeBlanceDate(iBalanceDate AS DATE):
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days WHERE closed_days.balance_date = iBalanceDate NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN ERROR-NOT-FOUND.
        
        closed_days.closed      = true.

        RETURN "".
    END.
    
    METHOD STATIC PUBLIC CHARACTER validBalanceDate(iBalanceDate AS DATE):
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days WHERE closed_days.balance_date = iBalanceDate NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN ERROR-NOT-FOUND.
        
        IF closed_days.closed = TRUE THEN RETURN ERROR-DAY-CLOSED + ":Date is closed for operations " + string(iBalanceDate) +  "!".

        RETURN "".
    END.
    
END CLASS.