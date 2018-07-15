CLASS globalSettings INHERITS systemSettingsApi:
    DEFINE PUBLIC PROPERTY g-today AS DATE NO-UNDO
        PUBLIC GET.
        PRIVATE SET.
    
    DEFINE PUBLIC PROPERTY companyName AS CHAR NO-UNDO
        PUBLIC GET.
        PRIVATE SET.

    DEFINE PUBLIC PROPERTY companyRegNr AS CHAR NO-UNDO
        PUBLIC GET.
        PRIVATE SET.


    CONSTRUCTOR globalSettings():
        Init().
    END.
    
    DESTRUCTOR globalSettings():
    
    END.
    
    METHOD PUBLIC CHARACTER Init():
        IF g-today      = ?  THEN g-today      = getWorkDay().
        IF companyName  = "" THEN companyName  = getValueChar("Company/Name").
        IF companyRegNr = "" THEN companyRegNr = getValueChar("Company/RegNr").
    END.

    METHOD PUBLIC DATE getWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN ?.

        RETURN closed_days.system_date.
    END.
    
END CLASS.