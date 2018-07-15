/*
********************************************************************************
********************************************************************************
12.07.2018 22:48   ABS SYSTEM                                       Alan Meister
--------------------------------------------------------------------------------
POS FUNCTION DESCRIPTION                                                 SUBMENU
================================================================================
1   CLIENTS  Clients main menu                                                 >
================================================================================
Find menu         [************************************************************]
*/
CLASS headerForm:
DEFINE VARIABLE Settings    AS globalSettings.

DEFINE VARIABLE g-today     AS DATE NO-UNDO.
DEFINE VARIABLE companyName AS CHARACTER NO-UNDO.
DEFINE VARIABLE loginName   AS CHARACTER NO-UNDO.


CONSTRUCTOR headerForm():
    Settings = NEW globalSettings().
    
    g-today     = Settings:g-today.
    companyName = Settings:companyName.
    loginName   = Settings:loginName.
END.

DESTRUCTOR headerForm():
    DELETE OBJECT Settings NO-ERROR.
END.

/* 20 + 30 + 30 */
DEFINE FRAME headerFrame
      STRING(g-today, "dd.mm.yyyy")
  " " STRING(TIME, "hh:mm:ss")
  " " STRING(companyName, "X(29)")
  " " STRING(loginName, "X(20)")
  .
  
METHOD PUBLIC CHARACTER showHeaderFrame():
    VIEW FRAME headerFrame. PAUSE 0.
END.

END.