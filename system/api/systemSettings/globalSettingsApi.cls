CLASS globalSettingsApi INHERITS systemSettingsApi:
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

    DEFINE VARIABLE closedDaysApi AS closedDaysApi NO-UNDO.
        
    CONSTRUCTOR globalSettingsApi():
        closedDaysApi = NEW closedDaysApi().
        Init().
    END.

    DESTRUCTOR globalSettingsApi():
        DELETE OBJECT closedDaysApi NO-ERROR.
    END.
    
    METHOD PUBLIC CHARACTER Init():
        IF g-today      = ?  THEN g-today      = closedDaysApi:getLastWorkDay().
        IF companyName  = "" THEN companyName  = getValueChar("Company/Name").
        IF companyName  = ?  THEN companyName  = "Unknown".
        IF companyRegNr = "" THEN companyRegNr = getValueChar("Company/RegNr").
        
        IF loginName    = ? OR loginName = "" THEN loginName = OS-GETENV("LOGON").
        IF loginName    = ? OR loginName = "" THEN loginName = OS-GETENV("LOGNAME").
        IF loginName    = ? OR loginName = "" THEN loginName = OS-GETENV("USER").
        IF loginName    = ? OR loginName = "" THEN loginName = OS-GETENV("USERNAME").
        
        RETURN "".
    END.


END CLASS.