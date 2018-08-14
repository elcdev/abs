CLASS closedDaysApi:
    CONSTRUCTOR closedDaysApi():
        Init().
    END.
    
    DESTRUCTOR closedDaysApi():
    
    END.
    
    METHOD PUBLIC CHARACTER Init():

        RETURN "".
    END.

    METHOD PUBLIC DATE getLastWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN today.

        RETURN closed_days.system_date.
    END.

    METHOD PUBLIC CHAR createWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.

        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF AVAILABLE closed_days THEN RETURN "".

        CREATE closed_days.
        closed_days.system_date = today.
        closed_days.closed      = false.
        
        RETURN "".
    END.

    METHOD PUBLIC CHAR closeWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN "NO-WORKING-DAYS".
        closed_days.closed      = true.

        RETURN "".
    END.
END CLASS.