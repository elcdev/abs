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

    DEFINE PUBLIC PROPERTY loginName AS CHAR NO-UNDO
        PUBLIC GET.
        PRIVATE SET.

    DEFINE VARIABLE closedDays AS closedDays NO-UNDO.
        
    CONSTRUCTOR globalSettings():
        closedDays = NEW closedDays().
        Init().
    END.
    
    DESTRUCTOR globalSettings():
        DELETE OBJECT closedDays NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER Init():
        IF g-today      = ?  THEN g-today      = closedDays:getLastWorkDay().
        IF companyName  = "" THEN companyName  = getValueChar("Company/Name").
        IF companyRegNr = "" THEN companyRegNr = getValueChar("Company/RegNr").
        IF loginName    = "" THEN loginName    = OS-GETENV("LOGON").
        
        RETURN "".
    END.

    METHOD PUBLIC DATE getWorkDay():
        DEFINE BUFFER closed_days FOR closed_days.
        
        FIND LAST closed_days NO-LOCK NO-ERROR.
        IF NOT AVAILABLE closed_days THEN RETURN ?.

        RETURN closed_days.system_date.
    END.
    
END CLASS.