CLASS globalSettings INHERITS systemSettingsApi:
    DEFINE STATIC VARIABLE tUser         AS CHARACTER NO-UNDO.
    DEFINE STATIC VARIABLE tCompanyName  AS CHARACTER NO-UNDO.
    DEFINE STATIC VARIABLE tcompanyRegNr AS CHARACTER NO-UNDO.
    DEFINE STATIC VARIABLE tBalanceDate  AS DATE      NO-UNDO.
    DEFINE STATIC VARIABLE tMenuFunction AS CHARACTER  NO-UNDO.
    
    DEFINE STATIC PUBLIC PROPERTY BalanceDate AS DATE NO-UNDO
        PUBLIC GET:
            RETURN tBalanceDate.
        END.

    DEFINE STATIC PUBLIC PROPERTY Balance_Date AS DATE NO-UNDO
        PUBLIC GET:
            RETURN tBalanceDate.
        END.
        
    DEFINE STATIC PUBLIC PROPERTY g-today AS DATE NO-UNDO
        PUBLIC GET:
            RETURN tBalanceDate.
        END.
        PRIVATE SET.
    
    DEFINE STATIC PUBLIC PROPERTY companyName AS CHAR NO-UNDO
        PUBLIC GET:
            RETURN tCompanyName.
        END.
        PRIVATE SET.

    DEFINE STATIC PUBLIC PROPERTY companyRegNr AS CHAR NO-UNDO
        PUBLIC GET:
            RETURN tcompanyRegNr.
        END.
        PRIVATE SET.

    DEFINE STATIC PUBLIC PROPERTY loginName AS CHAR NO-UNDO
        PUBLIC GET:
            RETURN tUser.
        END.
        PRIVATE SET.

    DEFINE STATIC PUBLIC PROPERTY user AS CHAR NO-UNDO
        PUBLIC GET:
            RETURN tUser.
        END.
        PRIVATE SET.
        
    DEFINE STATIC PUBLIC PROPERTY currentMenuFunction AS CHAR NO-UNDO
        PUBLIC GET:
            RETURN tMenuFunction.
        END.
        PUBLIC SET(iValue AS CHAR):
            tMenuFunction = iValue.
        END.



    
    DEFINE STATIC VARIABLE InitDone AS LOG NO-UNDO INITIAL FALSE.
    
    CONSTRUCTOR STATIC globalSettings():
        Init().
    END.
    
    DESTRUCTOR globalSettings():
        
    END.
    
    METHOD STATIC PUBLIC CHARACTER Init():
        IF InitDone THEN RETURN "".
        InitDone = TRUE.

        IF tBalanceDate  = ?  THEN tBalanceDate  = closedDaysApi:getLastWorkDay().
        IF tCompanyRegNr = "" THEN tCompanyRegNr = getValueChar("Company/RegNr").
        IF tCompanyName  = "" THEN tCompanyName  = getValueChar("Company/Name").
        
        
        IF tCompanyName  = ?  THEN tCompanyName  = "Unknown Company".
        
        IF tUser    = ? OR tUser = "" THEN tUser = OS-GETENV("LOGON").
        IF tUser    = ? OR tUser = "" THEN tUser = OS-GETENV("LOGNAME").
        IF tUser    = ? OR tUser = "" THEN tUser = OS-GETENV("USER").
        IF tUser    = ? OR tUser = "" THEN tUser = OS-GETENV("USERNAME").
  
        RETURN "".
    END.

END CLASS.
