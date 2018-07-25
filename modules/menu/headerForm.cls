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
DEFINE VARIABLE Settings    AS globalSettingsApi.

DEFINE VARIABLE g-today     AS DATE NO-UNDO.
DEFINE VARIABLE companyName AS CHARACTER NO-UNDO.
DEFINE VARIABLE loginName   AS CHARACTER NO-UNDO.

/* 20 + 30 + 30 */
DEFINE FRAME headerFrame
      g-today FORMAT "99.99.9999"
  " " companyName FORMAT "X(29)"
  " " loginName FORMAT "X(20)"
  WITH NO-LABELS NO-BOX.
  
CONSTRUCTOR headerForm():
    Settings = NEW globalSettingsApi().
    
    g-today     = Settings:g-today.
    companyName = Settings:companyName.
    loginName   = Settings:loginName.
END.

DESTRUCTOR headerForm():
    DELETE OBJECT Settings NO-ERROR.
END.


METHOD PUBLIC CHARACTER showHeader():
    VIEW FRAME headerFrame. PAUSE 0.
END.

END.